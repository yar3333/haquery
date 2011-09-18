<?php

class haquery_server_HaqTools {
	public function __construct(){}
	static function serverVarToClientString($v) {
		$GLOBALS['%s']->push("haquery.server.HaqTools::serverVarToClientString");
		$»spos = $GLOBALS['%s']->length;
		if($v === null) {
			$GLOBALS['%s']->pop();
			return "null";
		}
		if($v === true) {
			$GLOBALS['%s']->pop();
			return "true";
		}
		if($v === false) {
			$GLOBALS['%s']->pop();
			return "false";
		}
		if(Type::typeof($v) == ValueType::$TInt) {
			$»tmp = Std::string($v);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		if(Type::typeof($v) == ValueType::$TObject) {
			if(Type::getClassName(Type::getClass($v)) === "String") {
				$»tmp = "StringTools.unescape(\"" . StringTools::escape($v) . "\")";
				$GLOBALS['%s']->pop();
				return $»tmp;
			}
			if(Type::getClassName(Type::getClass($v)) === "Date") {
				$date = $v;
				{
					$»tmp = "new Date(" . $date->getTime() . ")";
					$GLOBALS['%s']->pop();
					return $»tmp;
				}
			}
		}
		throw new HException("Can't convert this type from server to client (typeof = " . Type::typeof($v) . ").");
		$GLOBALS['%s']->pop();
	}
	static function getCallClientFunctionString($func, $params) {
		$GLOBALS['%s']->push("haquery.server.HaqTools::getCallClientFunctionString");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $func . "(" . (haquery_server_HaqTools_0($func, $params)) . ")";
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function hexClientIP() {
		$GLOBALS['%s']->push("haquery.server.HaqTools::hexClientIP");
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
		$GLOBALS['%s']->push("haquery.server.HaqTools::uuid");
		$»spos = $GLOBALS['%s']->length;
		$time = Math::floor(Date::now()->getTime() * 1000);
		{
			$»tmp = sprintf("%08s", _hx_substr(haquery_server_HaqTools::hexClientIP(), 0, 8)) . sprintf("-%08x", $time / 65536) . sprintf("-%04x", $time % 65536) . sprintf("-%04x", Math::floor(Math::random() * 65536)) . sprintf("%04x", Math::floor(Math::random() * 65536));
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'haquery.server.HaqTools'; }
}
function haquery_server_HaqTools_0(&$func, &$params) {
	if($params !== null) {
		return Lambda::map($params, (isset(haquery_server_HaqTools::$serverVarToClientString) ? haquery_server_HaqTools::$serverVarToClientString: array("haquery_server_HaqTools", "serverVarToClientString")))->join(", ");
	} else {
		return "";
	}
}
