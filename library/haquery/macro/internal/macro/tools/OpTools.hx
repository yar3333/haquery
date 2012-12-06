package haquery.macro.internal.macro.tools;

import haxe.macro.Expr;
using haquery.macro.internal.core.types.Outcome;
using haquery.macro.internal.macro.tools.MacroTools;

/**
 * ...
 * @author back2dos
 */

class BinopTools {
	static public function get(o:Binop, e:Expr) {
		return
			switch (e.expr) {
				case EBinop(op, e1, e2):
					if (Type.enumEq(o, op)) 
						{ e1: e1, e2:e2, pos:e.pos } .asSuccess();
					else 
						e.pos.makeFailure('expected ' + o + ' but found ' + op);
				default: 
					e.pos.makeFailure('expected binary operation ' + o);
			}
	}
	static public function getBinop(e:Expr) {
		return
			switch (e.expr) {
				case EBinop(op, e1, e2):
					{ e1: e1, e2:e2, op:op, pos:e.pos } .asSuccess();
				default:
					e.pos.makeFailure('expected binary operation but found ' + Type.enumConstructor(e.expr));					
			}
	}
	static public inline function make(op:Binop, e1:Expr, e2:Expr, ?pos) {
		return ExprTools.binOp(e1, e2, op, pos);
	}
}

class UnopTools {
	static public function get(o:Unop, e:Expr, postfix:Bool = false) {
		return
			switch (e.expr) {
				case EUnop(op, postFix, arg):
					if (postfix != postfix)
						e.pos.makeFailure(postfix ? 'expected postfix operator' : 'expected prefix operator');
					else if (!Type.enumEq(o, op)) 
						e.pos.makeFailure('expected ' + o + ' but found ' + op);
					else
						{ e: arg, pos:e.pos } .asSuccess();
				default: 
					e.pos.makeFailure('expected unary operation ' + o);
			}
	}
	static public function getUnop(e:Expr) {
		return
			switch (e.expr) {
				case EUnop(op, postFix, arg):
					{ op: op, postfix: postFix, e: arg, pos: e.pos } .asSuccess();
				default:
					e.pos.makeFailure('expected unary operation but found ' + Type.enumConstructor(e.expr));					
			}
	}
}