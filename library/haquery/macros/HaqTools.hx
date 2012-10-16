package haquery.macros;

#if macro
import haxe.macro.Context;
import sys.FileSystem;
import sys.io.File;
#end

import haxe.macro.Expr;
import haxe.macro.Type;

using haquery.StringTools;
using tink.macro.tools.MacroTools;

class HaqTools
{
	#if macro
	
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
		var type = Context.getType(fullName);
		switch (type)
		{
			case Type.TInst(t, _):
				return t.get();
			default:
				return null;
		}
	}
	
	public static function funArgsToFunctionArgs(params:Array<{ t:Type, opt:Bool, name:String }>) : Array<FunctionArg>
	{
		var r = new Array<FunctionArg>();
		for (param in params)
		{
			var type = safeToComplex(param.t);
			r.push(param.name.toArg(type, param.opt));
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
	
	public static function safeToComplex(type:Type) : ComplexType
	{
		switch (type)
		{
			case Type.TMono(t):
				return safeToComplex(t.get());
			
			case Type.TInst(t, params):
				var tt = t.get();
				return ComplexType.TPath(makeTypePath(tt.pack, tt.name, typesToTypeParams(params)));
			
			case Type.TEnum(t, params):
				var tt = t.get();
				return ComplexType.TPath(makeTypePath(tt.pack, tt.name, typesToTypeParams(params)));
			
			case Type.TAnonymous(a):
				var aa = a.get();
				return ComplexType.TAnonymous(Lambda.array(Lambda.map(aa.fields, classFieldToField)));
			
			default:
				return ComplexType.TPath("Dynamic".asTypePath());
		}
	}
	
	public static function typesToTypeParams(types:Array<Type>) : Array<TypeParam>
	{
		return Lambda.array(Lambda.map(types, function (t) return TypeParam.TPType(safeToComplex(t))));
	}
	
	public static function classFieldToField(field:ClassField) : Field
	{
		return {
			  name : field.name
			, doc : field.doc
			, access : []
			, kind : FieldType.FVar(safeToComplex(field.type))
			, pos : field.pos
			, meta : field.meta.get()
		};
	}
	
	public static function isVoid(t:Null<ComplexType>) : Bool
	{
		if (t != null)
		{
			switch (t)
			{
				case ComplexType.TPath(p):
					return p.pack.length == 0 && p.name == "Void";
				default:
			}
		}
		return false;
	}
	
	public static function isNull(t:Expr) : Bool
	{
		if (t != null)
		{
			switch (t.expr)
			{
				case ExprDef.EConst(c):
					switch (c)
					{
						case Constant.CIdent(s):
							return s == "null";
						default:
					}
				default:
			}
		}
		return false;
	}
	
	public static function stringConstExpr2string(expr:Expr) : String
	{
		switch (expr.expr)
		{
			case ExprDef.EConst(c):
				switch (c)
				{
					case Constant.CString(s): return s;
					default:
				}
			default:
		}
		return null;
	}
	
	#end
}