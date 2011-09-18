<?php

class Std {
	public function __construct(){}
	static function is($v, $t) {
		$GLOBALS['%s']->push("Std::is");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = _hx_instanceof($v, $t);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function string($s) {
		$GLOBALS['%s']->push("Std::string");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = _hx_string_rec($s, "");
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function int($x) {
		$GLOBALS['%s']->push("Std::int");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = intval($x);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function parseInt($x) {
		$GLOBALS['%s']->push("Std::parseInt");
		$»spos = $GLOBALS['%s']->length;
		if(!is_numeric($x)) {
			$matches = null;
			preg_match("/\\d+/", $x, $matches);
			{
				$»tmp = Std_0($matches, $x);
				$GLOBALS['%s']->pop();
				return $»tmp;
			}
		} else {
			$»tmp = Std_1($x);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function parseFloat($x) {
		$GLOBALS['%s']->push("Std::parseFloat");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = is_numeric($x) ? floatval($x) : acos(1.01);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function random($x) {
		$GLOBALS['%s']->push("Std::random");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = mt_rand(0, $x - 1);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'Std'; }
}
function Std_0(&$matches, &$x) {
	if(count($matches) === 0) {
		return null;
	} else {
		return intval($matches[0]);
	}
}
function Std_1(&$x) {
	if(strtolower(_hx_substr($x, 0, 2)) === "0x") {
		return (int) hexdec(substr($x, 2));
	} else {
		return intval($x);
	}
}
