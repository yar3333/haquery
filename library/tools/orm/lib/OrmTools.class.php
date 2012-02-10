<?php

class OrmTools {
	public function __construct(){}
	static function capitalize($s) {
		return OrmTools_0($s);
	}
	static function indent($text, $ind) {
		if($ind === null) {
			$ind = "\x09";
		}
		if($text === "") {
			return "";
		}
		return $ind . str_replace("\x0A", "\x0A" . $ind, $text);
	}
	static function splitFullClassName($fullClassName) {
		$packageName = "";
		$className = $fullClassName;
		if(_hx_last_index_of($fullClassName, ".", null) !== -1) {
			$packageName = _hx_substr($fullClassName, 0, _hx_last_index_of($fullClassName, ".", null));
			$className = _hx_substr($fullClassName, _hx_last_index_of($fullClassName, ".", null) + 1, null);
		}
		return _hx_anonymous(array("packageName" => $packageName, "className" => $className));
	}
	static function sqlTypeCheck($checked, $type) {
		$re = new EReg("^" . $type . "(\\(|\$)", "");
		return $re->match($checked);
	}
	static function sqlType2haxeType($sqlType) {
		$sqlType = strtoupper($sqlType);
		if($sqlType === "TINYINT(1)") {
			return "Bool";
		}
		if(OrmTools::sqlTypeCheck($sqlType, "TINYINT")) {
			return "Int";
		}
		if(OrmTools::sqlTypeCheck($sqlType, "SHORT")) {
			return "Int";
		}
		if(OrmTools::sqlTypeCheck($sqlType, "LONG")) {
			return "Int";
		}
		if(OrmTools::sqlTypeCheck($sqlType, "INT")) {
			return "Int";
		}
		if(OrmTools::sqlTypeCheck($sqlType, "INT24")) {
			return "Int";
		}
		if(OrmTools::sqlTypeCheck($sqlType, "LONGLONG")) {
			return "Float";
		}
		if(OrmTools::sqlTypeCheck($sqlType, "DECIMAL")) {
			return "Float";
		}
		if(OrmTools::sqlTypeCheck($sqlType, "FLOAT")) {
			return "Float";
		}
		if(OrmTools::sqlTypeCheck($sqlType, "DOUBLE")) {
			return "Float";
		}
		if(OrmTools::sqlTypeCheck($sqlType, "DATE")) {
			return "Date";
		}
		if(OrmTools::sqlTypeCheck($sqlType, "DATETIME")) {
			return "Date";
		}
		return "String";
	}
	static function createVar($haxeName, $haxeType, $haxeDefVal) {
		return _hx_anonymous(array("name" => null, "type" => null, "isNull" => false, "isKey" => false, "isAutoInc" => false, "haxeName" => $haxeName, "haxeType" => $haxeType, "haxeDefVal" => $haxeDefVal));
	}
	static function field2var($f) {
		return _hx_anonymous(array("name" => $f->name, "type" => $f->type, "isNull" => $f->isNull, "isKey" => $f->isKey, "isAutoInc" => $f->isAutoInc, "haxeName" => $f->name, "haxeType" => OrmTools::sqlType2haxeType($f->type), "haxeDefVal" => (($f->name === "position") ? "null" : null)));
	}
	static function fields2vars($fields) {
		return Lambda::map($fields, (isset(OrmTools::$field2var) ? OrmTools::$field2var: array("OrmTools", "field2var")));
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
