package haquery.macro;

import sys.io.File;
import haxe.io.Path;
import stdlib.FileSystem;
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Printer;
using StringTools;
using haxe.macro.TypeTools;
using haquery.macro.HaqMacroTools;

class HaqBuild
{
	macro public static function startup()
	{
		defineClientServer();
		
		if (!Context.defined("display"))
		{
			Context.onGenerate(function(types:Array<Type>)
			{
				for (type in types)
				{
					switch (type)
					{
						case Type.TInst(t, params):
							var clas = t.get();
							if ((clas.name == "Server" || clas.name == "Client") && clas.isExtendsFrom("haquery.base.HaqComponent"))
							{
								checkConstructorExist(clas);
								
								if (clas.name == "Server")
								{
									generateSharedServer(clas);
								}
								else
								if (clas.name == "Client")
								{
									generateSharedClient(clas);
								}
							}
							
						default:
					}
				}
			});
		}
		
		return macro null;
	}
	
	static function defineClientServer()
	{
		var displayPos = Compiler.getDisplayPos();
		if (displayPos != null)
		{
			var file = displayPos.file.toLowerCase();
			for (cp in Context.getClassPath())
			{
				cp = FileSystem.fullPath(cp).toLowerCase();
				if (file.startsWith(cp))
				{
					file = file.substr(cp.length);
					break;
				}
			}
			
			if (file.startsWith("models\\server\\") || file.endsWith("\\server.hx"))
			{
				Compiler.define("server");
			}
			else
			if (file.startsWith("models\\client\\") || file.endsWith("\\client.hx"))
			{
				Compiler.define("client");
			}
			else
			{
				// TODO: smart #if-else-end parser
				var text = File.getContent(displayPos.file).replace("\r\n", "\n").substr(0, displayPos.pos);
				var reDefine = ~/#if\s+(client|server)\b/;
				var def = "";
				var pos = 0; while (pos < text.length && reDefine.matchSub(text, pos))
				{
					def = reDefine.matched(1);
					pos = reDefine.matchedPos().pos + reDefine.matchedPos().len;
				}
				if (def != "") Compiler.define(def);
			}
		}
	}
	
	static function checkConstructorExist(clas:ClassType)
	{
		if (clas.constructor == null)
		{
			Context.error("Please, add the constructor to the " + clas.pack.join(".") + "." + clas.name + " class due haxe bug #2117.\nInsert the next line into your code for workaround:\nfunction new() super();", clas.pos);
		}
	}
	
	static function generateSharedServer(componentClass:ClassType)
	{
		generateModuleIfNeed("SharedServer", "haquery.client.HaqComponent", componentClass, function(_)
		{
			return [ 
				  "component".makeVar(macro : haquery.client.HaqComponent)
				, "new".makeMethod([ "component".toArg(macro : haquery.client.HaqComponent) ], macro : Void, macro { this.component = component; })
			].concat(
				mapMetaMarkedMethodsToFields("shared", componentClass, 
					function(name:String, args:Array<FunctionArg>, ret:Null<ComplexType>, pos:Position) : Field
					{
						var args2 : Array<FunctionArg> = Reflect.copy(args);
						args2.push("success".toArg(macro : $ret->Void, true));
						args2.push("fail".toArg(macro : stdlib.Exception->Void, true));
						var callParams = [ 
							  name.toExpr(pos)
							, Lambda.map(args, function(a) return Context.parse(a.name, pos)).toArray()
							, !ret.isVoid() ? macro success : macro function(_) if (success != null) success()
							, macro fail
						];
						var callExpr = ExprDef.EBlock( [ ExprDef.ECall(macro component.callSharedServerMethod, callParams).at(pos) ] ).at(pos);
						return name.makeMethod(args2, macro : Void, callExpr);
					}
				)
			);
		});
	}
	
	static function generateSharedClient(componentClass:ClassType)
	{
		generateModuleIfNeed("SharedClient", "haquery.server.HaqComponent", componentClass, function(_)
		{
			return [ 
				  "component".makeVar(macro : haquery.server.HaqComponent)
				, "new".makeMethod([ "component".toArg(macro : haquery.server.HaqComponent) ], macro : Void, macro { this.component = component; })
			].concat(
				mapMetaMarkedMethodsToFields("shared", componentClass, 
					function(name:String, args:Array<FunctionArg>, ret:Null<ComplexType>, pos:Position) : Field
					{
						var callParams = [ 
							  macro $v{name}
							, Lambda.map(args, function(a) return Context.parse(a.name, pos)).toArray()
						];
						var callExpr = ExprDef.EBlock([ ExprDef.ECall(macro component.callSharedClientMethodDelayed, callParams).at(pos) ]).at(pos);
						return name.makeMethod(args, macro : Void, callExpr);
					}
				)
			);
		});
	}
	
	static function generateModuleIfNeed(generateClassName:String, baseComponentClassName:String, componentClass:ClassType, generateFunc:ClassType->Array<Field>)
	{
		var componentModulePath = Context.resolvePath(StringTools.replace(componentClass.module, ".", "/") + ".hx");
		var dstModulePath = "gen/" + componentClass.pack.join("/") + "/" + generateClassName + ".hx";
		if (!FileSystem.exists(dstModulePath) || FileSystem.stat(componentModulePath).mtime.getTime() > FileSystem.stat(dstModulePath).mtime.getTime())
		{
			var printer = new Printer();
			var renderedClassFields = Lambda.map(generateFunc(componentClass), function(f) return printer.printField(f) + ";\n").join("\n");
			renderedClassFields = StringTools.replace(renderedClassFields, "};", "}");
			renderedClassFields = StringTools.replace(renderedClassFields, "StdTypes.Void", "Void");
			renderedClassFields = "\t" + renderedClassFields.rtrim().replace("\n", "\n\t") + "\n";
			
			var s = "// This is autogenerated file. Do not edit!\n"
				  + "\n"
				  + "package " + componentClass.pack.join(".") + ";\n"
				  + "\n"
				  + "@:access(" + baseComponentClassName +")\n"
				  + "class " + generateClassName + "\n"
				  + "{\n"
				  + renderedClassFields
				  + "}\n";
			
			FileSystem.createDirectory(Path.directory(dstModulePath));
			File.saveContent(dstModulePath, s);
		}
	}
	
	static function mapMetaMarkedMethodsToFields(metaMark:String, componentClass:ClassType, mapFunc:String->Array<FunctionArg>->Null<ComplexType>->Position->Field) : Array<Field>
	{
		var r = new Array<Field>();
		
		for (field in componentClass.fields.get())
		{
			if (field.meta.has(metaMark))
			{
				var typedFieldExpr = field.expr();
				if (typedFieldExpr != null)
				{
					var fieldExpr = Context.getTypedExpr(field.expr());
					if (fieldExpr != null)
					{
						if (fieldExpr.expr != null)
						{
							switch (fieldExpr.expr)
							{
								case ExprDef.EFunction(name, f):
										r.push(mapFunc(field.name, f.args, f.ret, componentClass.pos));
								
								default:
									Context.error("Use @shared for methods only.", field.pos);
							}
						}
					}
				}
				else
				{
					switch (field.type)
					{
						case Type.TFun(args, ret):
							r.push(mapFunc(field.name, args.funArgsToFunctionArgs(), ret.toComplexType(), componentClass.pos));
						
						default:
							Context.error("Use @shared for methods only.", field.pos);
					}
				}
			}
		}
		
		if (componentClass.superClass != null)
		{
			r = r.concat(mapMetaMarkedMethodsToFields(metaMark, componentClass.superClass.t.get(), mapFunc));
		}
		
		return r;	
	}
}