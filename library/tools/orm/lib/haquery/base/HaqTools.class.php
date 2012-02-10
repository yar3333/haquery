<?php

class haquery_base_HaqTools {
	public function __construct(){}
	static function isClassHasSuperClass($c, $superClass) {
		while($c !== null) {
			if($c === $superClass) {
				return true;
			}
			$c = Type::getSuperClass($c);
		}
		return false;
	}
	static function bool($v) {
		return !_hx_equal($v, false) && $v !== null && !_hx_equal($v, 0) && !_hx_equal($v, "") && !_hx_equal($v, "0") && !_hx_equal($v, "false") && !_hx_equal($v, "off");
	}
	static function object2hash($obj) {
		$r = new Hash();
		{
			$_g = 0; $_g1 = Reflect::fields($obj);
			while($_g < $_g1->length) {
				$field = $_g1[$_g];
				++$_g;
				$r->set($field, Reflect::field($obj, $field));
				unset($field);
			}
		}
		return $r;
	}
	static function getNumeral($n, $w1, $w2, $w3) {
		if($n % 10 === 0 || $n >= 11 && $n <= 19 || $n % 10 >= 5) {
			return $w3;
		}
		if($n % 10 >= 2 && $n % 10 <= 4) {
			return $w2;
		}
		return $w1;
	}
	static function serverVarToClientString($v) {
		$»t = (Type::typeof($v));
		switch($»t->index) {
		case 0:
		{
			return "null";
		}break;
		case 3:
		{
			return (($v) ? "true" : "false");
		}break;
		case 1:
		case 2:
		{
			return Std::string($v);
		}break;
		case 4:
		{
			return "haquery.StringTools.unescape(\"" . haquery_StringTools::escape($v) . "\")";
		}break;
		case 6:
		$clas = $»t->params[0];
		{
			if(Type::getClassName($clas) === "String") {
				return "haquery.StringTools.unescape(\"" . haquery_StringTools::escape($v) . "\")";
			}
			if(Type::getClassName($clas) === "Date") {
				$date = $v;
				return "new Date(" . $date->getTime() . ")";
			}
		}break;
		default:{
		}break;
		}
		throw new HException("Can't convert this type from server to client (typeof = " . Type::typeof($v) . ").");
	}
	static function getCallClientFunctionString($func, $params) {
		return $func . "(" . ((($params !== null) ? Lambda::map($params, (isset(haquery_base_HaqTools::$serverVarToClientString) ? haquery_base_HaqTools::$serverVarToClientString: array("haquery_base_HaqTools", "serverVarToClientString")))->join(", ") : "")) . ")";
	}
	static function hexClientIP() {
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
		return $hex;
	}
	static function uuid() {
		$time = Math::floor(Date::now()->getTime());
		return sprintf("%08s", _hx_substr(haquery_base_HaqTools::hexClientIP(), 0, 8)) . sprintf("-%08x", $time / 65536) . sprintf("-%04x", $time % 65536) . sprintf("-%04x", Math::floor(Math::random() * 65536)) . sprintf("%04x", Math::floor(Math::random() * 65536));
	}
	function __toString() { return 'haquery.base.HaqTools'; }
}
