<?php

class haquery_base_HaqTools {
	public function __construct(){}
	static function getNumeral($n, $w1, $w2, $w3) {
		$GLOBALS['%s']->push("haquery.base.HaqTools::getNumeral");
		$»spos = $GLOBALS['%s']->length;
		if($n % 10 === 0 || $n >= 11 && $n <= 19 || $n % 10 > 5) {
			$GLOBALS['%s']->pop();
			return $w3;
		}
		if($n % 10 >= 2 && $n % 10 <= 4) {
			$GLOBALS['%s']->pop();
			return $w2;
		}
		{
			$GLOBALS['%s']->pop();
			return $w1;
		}
		$GLOBALS['%s']->pop();
	}
	static function serverVarToClientString($v) {
		$GLOBALS['%s']->push("haquery.base.HaqTools::serverVarToClientString");
		$»spos = $GLOBALS['%s']->length;
		$»t = (Type::typeof($v));
		switch($»t->index) {
		case 0:
		{
			$GLOBALS['%s']->pop();
			return "null";
		}break;
		case 3:
		{
			$»tmp = (($v) ? "true" : "false");
			$GLOBALS['%s']->pop();
			return $»tmp;
		}break;
		case 1:
		case 2:
		{
			$»tmp = Std::string($v);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}break;
		case 4:
		{
			$»tmp = "haquery.StringTools.unescape(\"" . haquery_StringTools::escape($v) . "\")";
			$GLOBALS['%s']->pop();
			return $»tmp;
		}break;
		case 6:
		$clas = $»t->params[0];
		{
			if(Type::getClassName($clas) === "String") {
				$»tmp = "haquery.StringTools.unescape(\"" . haquery_StringTools::escape($v) . "\")";
				$GLOBALS['%s']->pop();
				return $»tmp;
			}
			if(Type::getClassName($clas) === "Date") {
				$date = $v;
				{
					$»tmp = "new Date(" . $date->getTime() . ")";
					$GLOBALS['%s']->pop();
					return $»tmp;
				}
			}
		}break;
		default:{
		}break;
		}
		throw new HException("Can't convert this type from server to client (typeof = " . Type::typeof($v) . ").");
		$GLOBALS['%s']->pop();
	}
	static function getCallClientFunctionString($func, $params) {
		$GLOBALS['%s']->push("haquery.base.HaqTools::getCallClientFunctionString");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $func . "(" . ((($params !== null) ? Lambda::map($params, (isset(haquery_base_HaqTools::$serverVarToClientString) ? haquery_base_HaqTools::$serverVarToClientString: array("haquery_base_HaqTools", "serverVarToClientString")))->join(", ") : "")) . ")";
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function hexClientIP() {
		$GLOBALS['%s']->push("haquery.base.HaqTools::hexClientIP");
		$»spos = $GLOBALS['%s']->length;
		$ip = $_SERVER['REMOTE_ADDR'];
		$parts = _hx_explode(".", $ip);
		$hex = "";
		{
			$_g = 0;
			while($_g < $parts->length) {
				$part = $parts[$_g];
				++$_g;
				$hex .= sprintf("%02x", $part);
				unset($part);
			}
		}
		{
			$GLOBALS['%s']->pop();
			return $hex;
		}
		$GLOBALS['%s']->pop();
	}
	static function uuid() {
		$GLOBALS['%s']->push("haquery.base.HaqTools::uuid");
		$»spos = $GLOBALS['%s']->length;
		$time = Math::floor(Date::now()->getTime());
		{
			$»tmp = sprintf("%08s", _hx_substr(haquery_base_HaqTools::hexClientIP(), 0, 8)) . sprintf("-%08x", $time / 65536) . sprintf("-%04x", $time % 65536) . sprintf("-%04x", Math::floor(Math::random() * 65536)) . sprintf("%04x", Math::floor(Math::random() * 65536));
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function isClassHasSuperClass($c, $superClass) {
		$GLOBALS['%s']->push("haquery.base.HaqTools::isClassHasSuperClass");
		$»spos = $GLOBALS['%s']->length;
		while($c !== null) {
			if($c === $superClass) {
				$GLOBALS['%s']->pop();
				return true;
			}
			$c = Type::getSuperClass($c);
		}
		{
			$GLOBALS['%s']->pop();
			return false;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'haquery.base.HaqTools'; }
}
