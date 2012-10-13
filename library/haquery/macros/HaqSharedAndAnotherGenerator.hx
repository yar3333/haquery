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

class HaqSharedAndAnotherGenerator
{
	#if macro
	
	public static function generate(clas:ClassType)
	{
		if (clas.pack.length > 0 && (clas.pack[0] == "components" || clas.pack[0] == "pages") && (clas.name == "Server" || clas.name == "Client"))
		{
			if (clas.name == "Server")
			{
				generateSharedServer(clas);
				generateAnotherServerForServer(clas);
				generateAnotherServerForClient(clas);
			}
			else
			{
				generateSharedClient(clas);
				generateAnotherClientForServer(clas);
				generateAnotherClientForClient(clas);
			}
		}
	}
	
	static function generateSharedServer(componentClass:ClassType)
	{
		generateModuleIfNeed("SharedServer", componentClass, function(_)
		{
			return [ 
				  HaqTools.makeVar("component", "haquery.client.HaqComponent".asComplexType())
				, HaqTools.makeConstructor(
					[
						"component".toArg("haquery.client.HaqComponent".asComplexType()) 
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
						args2.push("callb".toArg(macro : $ret->Void, true));
						var callParams = [ 
							  name.toExpr()
							, Lambda.map(args, function(a) return Context.parse(a.name, pos)).toArray()
							, !HaqTools.isVoid(ret) ? macro callb : macro function(_) callb()
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
				  HaqTools.makeVar("component", "haquery.server.HaqComponent".asComplexType())
				, HaqTools.makeConstructor(
					[ 
						"component".toArg("haquery.server.HaqComponent".asComplexType()) 
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
	
	static function generateAnotherServerForServer(componentClass:ClassType)
	{
		generateModuleIfNeed("AnotherServerForServer", componentClass, function(_)
		{
			return [ 
				  HaqTools.makeVar("pageKey", "String".asComplexType())
				, HaqTools.makeVar("component", "haquery.server.HaqComponent".asComplexType())
				, HaqTools.makeConstructor(
					[ 
						  "pageKey".toArg("String".asComplexType())
						, "component".toArg("haquery.server.HaqComponent".asComplexType()) 
					],
					macro 
					{
						this.pageKey = pageKey;
						this.component = component;
					}
				  )
			].concat(
				mapMetaMarkedMethodsToFields("another", componentClass,
					function(name:String, args:Array<FunctionArg>, ret:Null<ComplexType>, pos:Position) : Field
					{
						var callParams = [ macro this.component.fullID, name.toExpr(), Lambda.map(args, function(a) return Context.parse(a.name, pos)).toArray() ];
						var callExpr = ExprDef.ECall(macro haquery.server.Lib.pages.get(this.pageKey).callServerMethod, callParams).at(pos);
						return HaqTools.makeMethod(name, args, ret, macro { return $callExpr; } );
					}
				)
			);
		});
	}

	static function generateAnotherServerForClient(componentClass:ClassType)
	{
	}
	
	static function generateAnotherClientForServer(componentClass:ClassType)
	{
	}
	
	static function generateAnotherClientForClient(componentClass:ClassType)
	{
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
	
	#end
}