<?php

class php_Stack {
	public function __construct(){}
	static function nativeExceptionStack() {
		$GLOBALS['%s']->push("php.Stack::nativeExceptionStack");
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
	function __toString() { return 'php.Stack'; }
}
