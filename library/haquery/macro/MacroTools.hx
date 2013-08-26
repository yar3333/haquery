package haquery.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

class MacroTools
{
	static public inline function toArg(name:String, ?t, ?opt = false, ?value = null) : FunctionArg
	{
		return
		{
			name: name,
			opt: opt,
			type: t,
			value: value
		};
	}
	
	static public inline function toExpr(v:Dynamic, ?pos:Position)
		return Context.makeExpr(v, pos);
		
	static public function toComplex(type:Type, ?pretty = false) : ComplexType
	{
		var ret = haxe.macro.TypeTools.toComplexType(type);
		if (ret == null)
		{
			//ret = lazyComplex(function () return type);	
		}
		return ret;
	}
	
	/*static function lazyComplex(f:Void->Type)
	{
		return TPath({
			pack : ['haxe','macro'],
			name : 'MacroType',
			params : [TPExpr(call(resolve('haquery.macro.internal.macro.Types.getType'), [toExpr(register(f))]))],
			sub : null,				
		});
	}*/
	
	static public inline function resolve(s:String, ?pos) 
		return drill(s.split('.'), pos);	
	
	static public function drill(parts:Array<String>, ?pos:Position, ?target:Expr)
	{
		if (target == null) target = at(EConst(CIdent(parts.shift())), pos);
		for (part in parts) target = field(target, part, pos);
		return target;		
	}
	
	static public inline function at(e:ExprDef, ?pos:Position) 
		return {
			expr: e,
			pos: pos
		};
		
	static public inline function field(e, field, ?pos)
		return at(EField(e, field), pos);
		
	static public inline function call(e, ?params, ?pos)
		return at(ECall(e, params == null ? [] : params), pos);
		
	static public function asTypePath(s:String, ?params) : TypePath
	{
		var parts = s.split('.');
		var name = parts.pop();
		var sub = null;
		if (parts.length > 0 && parts[parts.length - 1].charCodeAt(0) < 0x5B)
		{
			sub = name;
			name = parts.pop();
			if(sub == name) sub = null;
		}
		return {
			name: name,
			pack: parts,
			params: params == null ? [] : params,
			sub: sub
		};
	}
	
	static public inline function asComplexType(s:String, ?params) 
		return TPath(asTypePath(s, params));	
	
	static public inline function toArray(exprs:Iterable<Expr>, ?pos) 
	return at(EArrayDecl(Lambda.array(exprs)), pos);		
}