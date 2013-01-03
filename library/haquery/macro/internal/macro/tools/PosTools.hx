package haquery.macro.internal.macro.tools;

import haxe.macro.Context;
import haxe.macro.Expr;
import haquery.macro.internal.core.types.Outcome;

/**
 * ...
 * @author back2dos
 */
using haquery.macro.internal.macro.tools.PosTools;
using haquery.macro.internal.core.types.Outcome;

class PosTools {

	static public function getOutcome < D, F > (pos:Position, outcome:Outcome < D, F > ) {
		return 
			switch (outcome) {
				case Success(d): d;
				case Failure(f): pos.error(f);
			}
	}
	static public function makeBlankType(pos:Position):ComplexType {
		return TypeTools.toComplex(Context.typeof(macro null));
	}	
	static public inline function getPos(pos:Position) {
		return 
			if (pos == null) 
				Context.currentPos();
			else
				pos;
	}
	static public function at(pos:Position, e:Expr) {
		return ExprTools.transform(e, function (e:Expr) {
			return e;
		}, pos);
	}
	static public function errorExpr(pos:Position, error:Dynamic) {
		return Bouncer.bounce(function ():Expr {
			return PosTools.error(pos, error);
		}, pos);		
	}
	static public inline function error(pos:Position, error:Dynamic):Dynamic {
		return Context.error(Std.string(error), pos);
	}
	///used to easily construct failed outcomes
	static public function makeFailure<A, Reason>(pos:Position, reason:Reason):Outcome<A, MacroError<Reason>> {
		return Failure(new MacroError(reason, pos));
	}
}

private class MacroError<Data> implements ThrowableFailure {
	public var data(default, null):Data;
	public var pos(default, null):Position;
	public function new(data:Data, ?pos:Position) {
		this.data = data;
		this.pos =
			if (pos == null) 
				Context.currentPos();
			else 
				pos;
	}
	public function toString() {
		return 'Error@' + Std.string(pos) + ': ' + Std.string(data);
	}
	public function throwSelf():Dynamic {
		return Context.error(Std.string(data), pos);
	}
}