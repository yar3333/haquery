<?php

class OrmTools {
	public function __construct(){}
	static function capitalize($s) {
		$GLOBALS['%s']->push("OrmTools::capitalize");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = OrmTools_0($s);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function indent($text, $ind) {
		$GLOBALS['%s']->push("OrmTools::indent");
		$製pos = $GLOBALS['%s']->length;
		if($ind === null) {
			$ind = "\x09";
		}
		if($text === "") {
			$GLOBALS['%s']->pop();
			return "";
		}
		{
			$裨mp = $ind . str_replace("\x0A", "\x0A" . $ind, $text);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function splitFullClassName($fullClassName) {
		$GLOBALS['%s']->push("OrmTools::splitFullClassName");
		$製pos = $GLOBALS['%s']->length;
		$packageName = "";
		$className = $fullClassName;
		if(_hx_last_index_of($fullClassName, ".", null) !== -1) {
			$packageName = _hx_substr($fullClassName, 0, _hx_last_index_of($fullClassName, ".", null));
			$className = _hx_substr($fullClassName, _hx_last_index_of($fullClassName, ".", null) + 1, null);
		}
		{
			$裨mp = _hx_anonymous(array("packageName" => $packageName, "className" => $className));
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function sqlTypeCheck($checked, $type) {
		$GLOBALS['%s']->push("OrmTools::sqlTypeCheck");
		$製pos = $GLOBALS['%s']->length;
		$re = new EReg("^" . $type . "(\\(|\$)", "");
		{
			$裨mp = $re->match($checked);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function sqlType2haxeType($sqlType) {
		$GLOBALS['%s']->push("OrmTools::sqlType2haxeType");
		$製pos = $GLOBALS['%s']->length;
		$sqlType = strtoupper($sqlType);
		if($sqlType === "TINYINT(1)") {
			$GLOBALS['%s']->pop();
			return "Bool";
		}
		if(OrmTools::sqlTypeCheck($sqlType, "TINYINT")) {
			$GLOBALS['%s']->pop();
			return "Int";
		}
		if(OrmTools::sqlTypeCheck($sqlType, "SHORT")) {
			$GLOBALS['%s']->pop();
			return "Int";
		}
		if(OrmTools::sqlTypeCheck($sqlType, "LONG")) {
			$GLOBALS['%s']->pop();
			return "Int";
		}
		if(OrmTools::sqlTypeCheck($sqlType, "INT")) {
			$GLOBALS['%s']->pop();
			return "Int";
		}
		if(OrmTools::sqlTypeCheck($sqlType, "INT24")) {
			$GLOBALS['%s']->pop();
			return "Int";
		}
		if(OrmTools::sqlTypeCheck($sqlType, "LONGLONG")) {
			$GLOBALS['%s']->pop();
			return "Float";
		}
		if(OrmTools::sqlTypeCheck($sqlType, "DECIMAL")) {
			$GLOBALS['%s']->pop();
			return "Float";
		}
		if(OrmTools::sqlTypeCheck($sqlType, "FLOAT")) {
			$GLOBALS['%s']->pop();
			return "Float";
		}
		if(OrmTools::sqlTypeCheck($sqlType, "DOUBLE")) {
			$GLOBALS['%s']->pop();
			return "Float";
		}
		if(OrmTools::sqlTypeCheck($sqlType, "DATE")) {
			$GLOBALS['%s']->pop();
			return "Date";
		}
		if(OrmTools::sqlTypeCheck($sqlType, "DATETIME")) {
			$GLOBALS['%s']->pop();
			return "Date";
		}
		{
			$GLOBALS['%s']->pop();
			return "String";
		}
		$GLOBALS['%s']->pop();
	}
	static function createVar($haxeName, $haxeType, $haxeDefVal) {
		$GLOBALS['%s']->push("OrmTools::createVar");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = _hx_anonymous(array("name" => null, "type" => null, "isNull" => false, "isKey" => false, "isAutoInc" => false, "haxeName" => $haxeName, "haxeType" => $haxeType, "haxeDefVal" => $haxeDefVal));
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function field2var($f) {
		$GLOBALS['%s']->push("OrmTools::field2var");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = _hx_anonymous(array("name" => $f->name, "type" => $f->type, "isNull" => $f->isNull, "isKey" => $f->isKey, "isAutoInc" => $f->isAutoInc, "haxeName" => $f->name, "haxeType" => OrmTools::sqlType2haxeType($f->type), "haxeDefVal" => OrmTools_1($f)));
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function fields2vars($fields) {
		$GLOBALS['%s']->push("OrmTools::fields2vars");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = Lambda::map($fields, (isset(OrmTools::$field2var) ? OrmTools::$field2var: array("OrmTools", "field2var")));
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'OrmTools'; }
}
function OrmTools_0(&$s) {
	if(strlen($s) === 0) {
		return $s;
	} else {
		return strtoupper(_hx_substr($s, 0, 1)) . _hx_substr($s, 1, null);
	}
}
function OrmTools_1(&$f) {
	if($f->name === "position") {
		return "null";
	}
}
