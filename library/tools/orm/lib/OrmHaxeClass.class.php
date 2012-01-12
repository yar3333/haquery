<?php

class OrmHaxeClass {
	public function __construct($fullClassName, $baseFullClassName) {
		if(!php_Boot::$skip_constructor) {
		$this->fullClassName = $fullClassName;
		$this->baseFullClassName = $baseFullClassName;
		$this->imports = new _hx_array(array());
		$this->vars = new _hx_array(array());
		$this->methods = new _hx_array(array());
	}}
	public $fullClassName;
	public $baseFullClassName;
	public $imports;
	public $vars;
	public $methods;
	public function addImport($packageName) {
		$this->imports->push("import " . $packageName . ";");
	}
	public function addVar($v, $isPrivate, $isStatic) {
		if($isStatic === null) {
			$isStatic = false;
		}
		if($isPrivate === null) {
			$isPrivate = false;
		}
		$s = ((($isPrivate) ? "" : "public ")) . ((($isStatic) ? "static " : "")) . "var " . $v->haxeName . " : " . $v->haxeType . (OrmHaxeClass_0($this, $isPrivate, $isStatic, $v));
		$this->vars->push($s);
	}
	public function addMethod($name, $vars, $retType, $body, $isPrivate, $isStatic) {
		if($isStatic === null) {
			$isStatic = false;
		}
		if($isPrivate === null) {
			$isPrivate = false;
		}
		$header = ((($isPrivate) ? "" : "public ")) . ((($isStatic) ? "static  " : "")) . "function " . $name . "(" . Lambda::map($vars, array(new _hx_lambda(array(&$body, &$isPrivate, &$isStatic, &$name, &$retType, &$vars), "OrmHaxeClass_1"), 'execute'))->join(", ") . ") : " . $retType;
		php_Lib::println("\x09" . $header);
		$s = $header . "\x0A" . "\x09{\x0A" . OrmTools::indent(trim($body, null), "\x09\x09") . "\x0A" . "\x09}";
		$this->methods->push($s);
	}
	public function toString() {
		$clas = OrmTools::splitFullClassName($this->fullClassName);
		$s = "package " . $clas->packageName . ";\x0A" . "\x0A" . $this->imports->join("\x0A") . ((($this->imports->length > 0) ? "\x0A\x0A" : "")) . "class " . $clas->className . (OrmHaxeClass_2($this, $clas)) . "\x0A" . "{\x0A" . (OrmHaxeClass_3($this, $clas)) . (OrmHaxeClass_4($this, $clas)) . "}";
		return $s;
	}
	public function __call($m, $a) {
		if(isset($this->$m) && is_callable($this->$m))
			return call_user_func_array($this->$m, $a);
		else if(isset($this->�dynamics[$m]) && is_callable($this->�dynamics[$m]))
			return call_user_func_array($this->�dynamics[$m], $a);
		else if('toString' == $m)
			return $this->__toString();
		else
			throw new HException('Unable to call �'.$m.'�');
	}
	function __toString() { return $this->toString(); }
}
function OrmHaxeClass_0(&$�this, &$isPrivate, &$isStatic, &$v) {
	if($isStatic && $v->haxeDefVal !== null) {
		return " = " . $v->haxeDefVal;
	} else {
		return "";
	}
}
function OrmHaxeClass_1(&$body, &$isPrivate, &$isStatic, &$name, &$retType, &$vars, $v) {
	{
		return $v->haxeName . ":" . $v->haxeType . (OrmHaxeClass_5($�this, $body, $isPrivate, $isStatic, $name, $retType, $v, $vars));
	}
}
function OrmHaxeClass_2(&$�this, &$clas) {
	if($�this->baseFullClassName !== null) {
		return " extends " . $�this->baseFullClassName;
	} else {
		return "";
	}
}
function OrmHaxeClass_3(&$�this, &$clas) {
	if($�this->vars->length > 0) {
		return "\x09" . $�this->vars->join(";\x0A\x09") . ";\x0A\x0A";
	} else {
		return "";
	}
}
function OrmHaxeClass_4(&$�this, &$clas) {
	if($�this->methods->length > 0) {
		return "\x09" . $�this->methods->join("\x0A\x0A\x09") . "\x0A";
	} else {
		return "";
	}
}
function OrmHaxeClass_5(&$�this, &$body, &$isPrivate, &$isStatic, &$name, &$retType, &$v, &$vars) {
	if($v->haxeDefVal !== null) {
		return "=" . $v->haxeDefVal;
	} else {
		return "";
	}
}
