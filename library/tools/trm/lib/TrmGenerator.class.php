<?php

class TrmGenerator {
	public function __construct(){}
	static function makeForComponents($componentsPackage) {
		$GLOBALS['%s']->push("TrmGenerator::makeForComponents");
		$»spos = $GLOBALS['%s']->length;
		$_g = 0; $_g1 = TrmTools::getClassPaths();
		while($_g < $_g1->length) {
			$classPath = $_g1[$_g];
			++$_g;
			$basePath = rtrim(str_replace("\\", "/", $classPath), "/") . "/";
			$path = $basePath . str_replace(".", "/", $componentsPackage);
			if(is_dir($path)) {
				TrmGenerator::makeForComponentsFolder($basePath, $componentsPackage);
			}
			unset($path,$classPath,$basePath);
		}
		$GLOBALS['%s']->pop();
	}
	static function makeForComponentsFolder($basePath, $componentsPackage) {
		$GLOBALS['%s']->push("TrmGenerator::makeForComponentsFolder");
		$»spos = $GLOBALS['%s']->length;
		haxe_Log::trace("TrmGenerator.makeForComponentsFolder", _hx_anonymous(array("fileName" => "TrmGenerator.hx", "lineNumber" => 27, "className" => "TrmGenerator", "methodName" => "makeForComponentsFolder")));
		haxe_Log::trace("basePath = " . $basePath, _hx_anonymous(array("fileName" => "TrmGenerator.hx", "lineNumber" => 28, "className" => "TrmGenerator", "methodName" => "makeForComponentsFolder")));
		haxe_Log::trace("componentsPackage = " . $componentsPackage, _hx_anonymous(array("fileName" => "TrmGenerator.hx", "lineNumber" => 29, "className" => "TrmGenerator", "methodName" => "makeForComponentsFolder")));
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'TrmGenerator'; }
}
