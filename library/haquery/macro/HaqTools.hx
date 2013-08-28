package haquery.macro;

#if (macro || display)
import haxe.macro.Context;
import sys.FileSystem;
import sys.io.File;
#end

import haxe.macro.Expr;
import haxe.macro.Type;
using stdlib.StringTools;
using haquery.macro.MacroTools;
using haxe.macro.TypeTools;

class HaqTools
{
	#if (macro || display)
	
	public static function log(s:String) : Void
	{
		if (sys.FileSystem.exists("build.log"))
		{
			var log = sys.io.File.append("build.log", false);
			log.writeString(s + "\n");
			log.close();
		}
		else
		{
			sys.io.File.saveContent("build.log", s + "\n");
		}
	}
	
	public static function isExtendsFrom(t:ClassType, parentClassPath:String) : Bool
	{
		while (t.superClass != null)
		{
			t = t.superClass.t.get();
			if (t.pack.join(".") + "." + t.name == parentClassPath)
			{
				return true;
			}
		}
		return false;
	}
	
	public static function getModuleType(module:String, typeName:String) : Type
	{
		for (type in Context.getModule(module))
		{
			switch(type)
			{
				case Type.TType(t, _):
					if (t.get().name == typeName) return t.get().type;
				
				default:
					return null;
			}
		}
		return null;
	}
	
	public static function getClassType(fullName:String) : ClassType
	{
		switch (Context.getType(fullName))
		{
			case Type.TInst(t, _):	return t.get();
			default:				return null;
		}
	}
	
	public static function funArgsToFunctionArgs(params:Array<{ t:Type, opt:Bool, name:String }>) : Array<FunctionArg>
	{
		var r = new Array<FunctionArg>();
		for (param in params)
		{
			r.push(param.name.toArg(param.t.toComplexType(), param.opt));
		}
		return r;
	}
	
	public static function makeTypePath(pack:Array<String>, name:String, ?params:Array<TypeParam>) : TypePath
	{
		return {
			  pack : pack
			, name : name
			, params : params != null ? params : []
			, sub : null
		};
	}
	
	public static function makeVar(name:String, type:ComplexType, ?expr:Expr) : Field
	{
		return {
			  name : name
			, access : []
			, kind : FieldType.FVar(type, expr)
			, pos : expr != null ? expr.pos : Context.currentPos()
		};
	}
	
	public static function makeMethod(name:String, args:Array<FunctionArg>, ret:Null<ComplexType>, expr:Expr) : Field
	{
		return {
			  name : name
			, access : [ Access.APublic ]
			, kind : FieldType.FFun({
						  args : args
						, ret : ret
						, expr : expr
						, params : []
					  })
			, pos : expr.pos
		};
	}
	
	public static function makeConstructor(args:Array<FunctionArg>, expr:Expr) : Field
	{
		return HaqTools.makeMethod("new", args, "Void".asComplexType(), expr);
	}
	
	public static function typesToTypeParams(types:Array<Type>) : Array<TypeParam>
	{
		return Lambda.array(Lambda.map(types, function (t) return TypeParam.TPType(t.toComplexType())));
	}
	
	public static function isVoid(t:Null<ComplexType>) : Bool
	{
		if (t != null)
		{
			switch (t)
			{
				case ComplexType.TPath(p):
					return p.name == "StdTypes" && p.pack.length == 0 && p.sub == "Void";
				default:
			}
		}
		return false;
	}
	
	#end
}