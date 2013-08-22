package haquery.macro;

#if macro

import haxe.macro.Printer;
import stdlib.FileSystem;
import sys.io.File;
import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haquery.macro.internal.macro.Tools;

class HaqSharedGenerator
{
	public static function generate(clas:ClassType)
	{
		if ((clas.name == "Server" || clas.name == "Client") && HaqTools.isExtendsFrom(clas, "haquery.base.HaqComponent"))
		{
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
	}
	
	static function generateSharedServer(componentClass:ClassType)
	{
		generateModuleIfNeed("SharedServer", componentClass, function(_)
		{
			return [ 
				  HaqTools.makeVar("component", macro : haquery.client.HaqComponent)
				, HaqTools.makeConstructor(
					[
						"component".toArg(macro : haquery.client.HaqComponent)
					],
					macro
					{
						this.component = component;
					}
				  )
			].concat(
				mapMetaMarkedMethodsToFields("shared", componentClass, 
					function(name:String, args:Array<FunctionArg>, ret:Null<ComplexType>, pos:Position) : Field
					{
						var args2 : Array<FunctionArg> = Reflect.copy(args);
						args2.push("success".toArg(macro : $ret->Void, true));
						args2.push("fail".toArg(macro : stdlib.Exception->Void, true));
						var callParams = [ 
							  name.toExpr()
							, Lambda.map(args, function(a) return Context.parse(a.name, pos)).toArray()
							, !HaqTools.isVoid(ret) ? macro success : macro function(_) if (success != null) success()
							, macro fail
						];
						var callExpr = ExprDef.EBlock( [ ExprDef.ECall(macro component.callSharedServerMethod, callParams).at(pos) ] ).at(pos);
						return HaqTools.makeMethod(name, args2, macro : Void, callExpr);
					}
				)
			);
		});
	}
	
	static function generateSharedClient(componentClass:ClassType)
	{
		generateModuleIfNeed("SharedClient", componentClass, function(_)
		{
			return [ 
				  HaqTools.makeVar("component", macro : haquery.server.HaqComponent)
				, HaqTools.makeConstructor(
					[
						"component".toArg(macro : haquery.server.HaqComponent)
					],
					macro
					{
						this.component = component;
					}
				  )
			].concat(
				mapMetaMarkedMethodsToFields("shared", componentClass, 
					function(name:String, args:Array<FunctionArg>, ret:Null<ComplexType>, pos:Position) : Field
					{
						var callParams = [ 
							  name.toExpr()
							, Lambda.map(args, function(a) return Context.parse(a.name, pos)).toArray()
						];
						var callExpr = ExprDef.EBlock([ ExprDef.ECall(macro component.callSharedClientMethodDelayed, callParams).at(pos) ]).at(pos);
						return HaqTools.makeMethod(name, args, macro : Void, callExpr);
					}
				)
			);
		});
	}
	
	static function generateModuleIfNeed(generateClassName:String, componentClass:ClassType, generateFunc:ClassType->Array<Field>)
	{
		var componentModulePath = Context.resolvePath(StringTools.replace(componentClass.module, ".", "/") + ".hx");
		var dstModulePath = "gen/" + componentClass.pack.join("/") + "/" + generateClassName + ".hx";
		if (!FileSystem.exists(dstModulePath) || FileSystem.stat(componentModulePath).mtime.getTime() > FileSystem.stat(dstModulePath).mtime.getTime())
		{
			var printer = new Printer();
			var renderedClassFields = Lambda.map(generateFunc(componentClass), function(f) return printer.printField(f) + ";\n").join("");
			renderedClassFields = StringTools.replace(renderedClassFields, "};", "}");
			renderedClassFields = StringTools.replace(renderedClassFields, "StdTypes.Void", "Void");
			
			var s = "// This is autogenerated file. Do not edit!\n"
				  + "\n"
				  + "package " + componentClass.pack.join(".") + ";\n"
				  + "\n"
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
							r.push(mapFunc(field.name, HaqTools.funArgsToFunctionArgs(args), HaqTools.safeToComplex(ret), componentClass.pos));
						
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

#end
