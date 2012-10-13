package haquery.macros;

#if macro
import haxe.macro.Context;
import haquery.server.FileSystem;
import sys.io.File;
import haxe.io.Path;
#end

import haxe.macro.Expr;
import haxe.macro.Type;

using tink.macro.tools.MacroTools;

class HaqSharedGenerator
{
	#if macro
	
	public static function generate(clas:ClassType)
	{
		if (clas.pack.length > 0 && (clas.pack[0] == "components" || clas.pack[0] == "pages") && (clas.name == "Server" || clas.name == "Client"))
		{
			if (clas.name == "Server")
			{
				generateModuleIfNeed("SharedServer", clas, function(clas:ClassType)
				{
					return [ 
						  HaqTools.makeVar("component", "haquery.client.HaqComponent".asComplexType(), null)
						, HaqTools.makeConstructor([ "component".toArg("haquery.client.HaqComponent".asComplexType()) ], macro { this.component = component; })
					].concat(
						  mapSharedMethodsToFields(clas, makeSharedServerClassMethod)
					);
				});
				
				generateModuleIfNeed("SharedAnotherServerForServer", clas, function(clas:ClassType)
				{
					return [];
				});
				
				generateModuleIfNeed("SharedAnotherServerForClient", clas, function(clas:ClassType)
				{
					return [];
				});
			}
			else
			{
				generateModuleIfNeed("SharedClient", clas, function(clas:ClassType)
				{
					return [ 
						  HaqTools.makeVar("component", "haquery.server.HaqComponent".asComplexType(), null)
						, HaqTools.makeConstructor([ "component".toArg("haquery.server.HaqComponent".asComplexType()) ], macro { this.component = component; })
					].concat(
						  mapSharedMethodsToFields(clas, makeSharedClientClassMethod)
					);
				});
				
				generateModuleIfNeed("SharedAnotherClientForServer", clas, function(clas:ClassType)
				{
					return [];
				});
				
				generateModuleIfNeed("SharedAnotherClientForClient", clas, function(clas:ClassType)
				{
					return [];
				});
			}
		}
	}
	
	static function generateModuleIfNeed(generateClassName:String, componentClass:ClassType, generateFunc:ClassType->Array<Field>)
	{
		var componentModulePath = Context.resolvePath(StringTools.replace(componentClass.module, ".", "/") + ".hx");
		var dstModulePath = "trm/" + componentClass.pack.join("/") + "/" + generateClassName + ".hx";
		if (!FileSystem.exists(dstModulePath) || FileSystem.stat(componentModulePath).mtime.getTime() > FileSystem.stat(dstModulePath).mtime.getTime())
		{
			var renderedClassFields = tink.macro.tools.Printer.printFields("", generateFunc(componentClass));
			renderedClassFields = StringTools.replace(renderedClassFields, "};", "}");
			
			var s = "// This is autogenerated file. Do not edit!\n"
				  + "\n"
				  + "package " + componentClass.pack.join(".") + ";\n"
				  + "\n"
				  + "class " + generateClassName + "\n"
				  + renderedClassFields;
			
			FileSystem.createDirectory(Path.directory(dstModulePath));
			File.saveContent(dstModulePath, s);
		}
	}
	
	static function mapSharedMethodsToFields(componentClass:ClassType, mapFunc:String->Array<FunctionArg>->Null<ComplexType>->Position->Field) : Array<Field>
	{
		var r = new Array<Field>();
		
		for (field in componentClass.fields.get())
		{
			if (field.meta.has("shared"))
			{
				var shared = Lambda.filter(field.meta.get(), function(m) return m.name == "shared").first();
				var IsWebsocketSupported = shared.params.length > 0 && HaqTools.stringConstExpr2string(shared.params[0]) == "websocket";
				
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
			r = r.concat(mapSharedMethodsToFields(componentClass.superClass.t.get(), mapFunc));
		}
		
		return r;	
	}
	
	static function makeSharedServerClassMethod(name:String, args:Array<FunctionArg>, ret:Null<ComplexType>, pos:Position) : Field
	{
		var args2 : Array<FunctionArg> = Reflect.copy(args);
		args2.push("callb".toArg(macro : $ret->Void, true));
		var callParams = [ 
			  name.toExpr()
			, Lambda.map(args, function(a) return Context.parse(a.name, pos)).toArray()
			, !HaqTools.isVoid(ret) ? macro callb : macro function(_) callb()
		];
		var callExpr = ExprDef.EBlock( [ ExprDef.ECall(macro component.callSharedServerMethod, callParams).at(pos) ] ).at(pos);
		return HaqTools.makeMethod(name, args2, macro : Void, callExpr);
	}
	
	static function makeSharedClientClassMethod(name:String, args:Array<FunctionArg>, ret:Null<ComplexType>, pos:Position) : Field
	{
		var callParams = [ 
			  name.toExpr()
			, Lambda.map(args, function(a) return Context.parse(a.name, pos)).toArray()
		];
		var callExpr = ExprDef.EBlock([ ExprDef.ECall(macro component.callSharedClientMethodDelayed, callParams).at(pos) ]).at(pos);
		return HaqTools.makeMethod(name, args, macro : Void, callExpr);
	}
	
	#end
}