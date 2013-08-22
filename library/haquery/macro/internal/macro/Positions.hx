package haquery.macro.internal.macro;

import haxe.macro.Context;
import haxe.macro.Expr;

using haquery.macro.internal.macro.Positions;
using haquery.macro.internal.core.Outcome;

class Positions {

	static public function getOutcome<D, F>(pos:Position, outcome:Outcome<D, F>):D {
		return 
			switch (outcome) {
				case Success(d): d;
				case Failure(f): pos.error(f);
			}
	}
	static public function makeBlankType(pos:Position):ComplexType 
		return Types.toComplex(Context.typeof(macro null));
		
	static public inline function getPos(pos:Position) {
		return 
			if (pos == null) 
				Context.currentPos();
			else
				pos;
	}
	static public function errorExpr(pos:Position, error:Dynamic) {
		return Bouncer.bounce(function ():Expr {
			return Positions.error(pos, error);
		}, pos);		
	}
	static public inline function error(pos:Position, error:Dynamic):Dynamic {
		return Context.error(Std.string(error), pos);
	}
	static public inline function warning<A>(pos:Position, warning:Dynamic, ?ret:A):A {
		Context.warning(Std.string(warning), pos);
		return ret;
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