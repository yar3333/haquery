<?php

class haxe_Stack {
	public function __construct(){}
	static function callStack() {
		$GLOBALS['%s']->push("haxe.Stack::callStack");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = haxe_Stack::makeStack("%s");
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function exceptionStack() {
		$GLOBALS['%s']->push("haxe.Stack::exceptionStack");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = haxe_Stack::makeStack("%e");
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function toString($stack) {
		$GLOBALS['%s']->push("haxe.Stack::toString");
		$»spos = $GLOBALS['%s']->length;
		$b = new StringBuf();
		{
			$_g = 0;
			while($_g < $stack->length) {
				$s = $stack[$_g];
				++$_g;
				$b->b .= "\x0ACalled from ";
				haxe_Stack::itemToString($b, $s);
				unset($s);
			}
		}
		{
			$»tmp = $b->b;
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function itemToString($b, $s) {
		$GLOBALS['%s']->push("haxe.Stack::itemToString");
		$»spos = $GLOBALS['%s']->length;
		$»t = ($s);
		switch($»t->index) {
		case 0:
		{
			$b->b .= "a C function";
		}break;
		case 1:
		$m = $»t->params[0];
		{
			$b->b .= "module ";
			$b->b .= $m;
		}break;
		case 2:
		$line = $»t->params[2]; $file = $»t->params[1]; $s1 = $»t->params[0];
		{
			if($s1 !== null) {
				haxe_Stack::itemToString($b, $s1);
				$b->b .= " (";
			}
			$b->b .= $file;
			$b->b .= " line ";
			$b->b .= $line;
			if($s1 !== null) {
				$b->b .= ")";
			}
		}break;
		case 3:
		$meth = $»t->params[1]; $cname = $»t->params[0];
		{
			$b->b .= $cname;
			$b->b .= ".";
			$b->b .= $meth;
		}break;
		case 4:
		$n = $»t->params[0];
		{
			$b->b .= "local function #";
			$b->b .= $n;
		}break;
		}
		$GLOBALS['%s']->pop();
	}
	static function makeStack($s) {
		$GLOBALS['%s']->push("haxe.Stack::makeStack");
		$»spos = $GLOBALS['%s']->length;
		if(!isset($GLOBALS[$s])) {
			$»tmp = new _hx_array(array());
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$a = $GLOBALS[$s];
		$m = new _hx_array(array());
		{
			$_g1 = 0; $_g = $a->length - (haxe_Stack_0($_g1, $a, $m, $s));
			while($_g1 < $_g) {
				$i = $_g1++;
				$d = _hx_explode("::", $a[$i]);
				$m->unshift(haxe_StackItem::Method($d[0], $d[1]));
				unset($i,$d);
			}
		}
		{
			$GLOBALS['%s']->pop();
			return $m;
		}
		$GLOBALS['%s']->pop();
	}
	static function nativeExceptionStack() {
		$GLOBALS['%s']->push("haxe.Stack::nativeExceptionStack");
		$»spos = $GLOBALS['%s']->length;
		$stack = new _hx_array($GLOBALS['%nativeExceptionCallStack']);
		{
			$_g1 = 0; $_g = $stack->length;
			while($_g1 < $_g) {
				$i = $_g1++;
				$stack[$i] = php_Lib::hashOfAssociativeArray($stack[$i]);
				if(_hx_array_get($stack, $i)->exists("args")) {
					$args = new _hx_array(_hx_array_get($stack, $i)->get("args"));
					if($args->length > 3) {
						$args[3] = new _hx_array($args[3]);
					}
					_hx_array_get($stack, $i)->set("args", $args);
					unset($args);
				}
				unset($i);
			}
		}
		{
			$GLOBALS['%s']->pop();
			return $stack;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'haxe.Stack'; }
}
function haxe_Stack_0(&$_g1, &$a, &$m, &$s) {
	if($s === "%s") {
		return 2;
	} else {
		return 0;
	}
}
