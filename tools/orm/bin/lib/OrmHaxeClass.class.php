<?php

class OrmHaxeClass {
	public function __construct($fullClassName, $baseFullClassName) {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("OrmHaxeClass::new");
		$»spos = $GLOBALS['%s']->length;
		$this->fullClassName = $fullClassName;
		$this->baseFullClassName = $baseFullClassName;
		$this->imports = new _hx_array(array());
		$this->vars = new _hx_array(array());
		$this->methods = new _hx_array(array());
		$GLOBALS['%s']->pop();
	}}
	public $fullClassName;
	public $baseFullClassName;
	public $imports;
	public $vars;
	public $methods;
	public function addImport($packageName) {
		$GLOBALS['%s']->push("OrmHaxeClass::addImport");
		$»spos = $GLOBALS['%s']->length;
		$this->imports->push("import " . $packageName . ";");
		$GLOBALS['%s']->pop();
	}
	public function addVar($v, $isPrivate, $isStatic) {
		$GLOBALS['%s']->push("OrmHaxeClass::addVar");
		$»spos = $GLOBALS['%s']->length;
		if($isStatic === null) {
			$isStatic = false;
		}
		if($isPrivate === null) {
			$isPrivate = false;
		}
		$s = (OrmHaxeClass_0($this, $isPrivate, $isStatic, $v)) . (OrmHaxeClass_1($this, $isPrivate, $isStatic, $v)) . "var " . $v->haxeName . " : " . $v->haxeType . (OrmHaxeClass_2($this, $isPrivate, $isStatic, $v));
		$this->vars->push($s);
		$GLOBALS['%s']->pop();
	}
	public function addMethod($name, $vars, $retType, $body, $isPrivate, $isStatic) {
		$GLOBALS['%s']->push("OrmHaxeClass::addMethod");
		$»spos = $GLOBALS['%s']->length;
		if($isStatic === null) {
			$isStatic = false;
		}
		if($isPrivate === null) {
			$isPrivate = false;
		}
		$header = (OrmHaxeClass_3($this, $body, $isPrivate, $isStatic, $name, $retType, $vars)) . (OrmHaxeClass_4($this, $body, $isPrivate, $isStatic, $name, $retType, $vars)) . "function " . $name . "(" . Lambda::map($vars, array(new _hx_lambda(array(&$body, &$isPrivate, &$isStatic, &$name, &$retType, &$vars), "OrmHaxeClass_5"), 'execute'))->join(", ") . ") : " . $retType;
		php_Lib::println("\x09" . $header);
		$s = $header . "\x0A" . "\x09{\x0A" . OrmTools::indent(trim($body, null), "\x09\x09") . "\x0A" . "\x09}";
		$this->methods->push($s);
		$GLOBALS['%s']->pop();
	}
	public function toString() {
		$GLOBALS['%s']->push("OrmHaxeClass::toString");
		$»spos = $GLOBALS['%s']->length;
		$clas = OrmTools::splitFullClassName($this->fullClassName);
		$s = "package " . $clas->packageName . ";\x0A" . "\x0A" . $this->imports->join("\x0A") . (OrmHaxeClass_6($this, $clas)) . "class " . $clas->className . (OrmHaxeClass_7($this, $clas)) . "\x0A" . "{\x0A" . (OrmHaxeClass_8($this, $clas)) . (OrmHaxeClass_9($this, $clas)) . "}";
		{
			$GLOBALS['%s']->pop();
			return $s;
		}
		$GLOBALS['%s']->pop();
	}
	public function __call($m, $a) {
		if(isset($this->$m) && is_callable($this->$m))
			return call_user_func_array($this->$m, $a);
		else if(isset($this->»dynamics[$m]) && is_callable($this->»dynamics[$m]))
			return call_user_func_array($this->»dynamics[$m], $a);
		else if('toString' == $m)
			return $this->__toString();
		else
			throw new HException('Unable to call «'.$m.'»');
	}
	function __toString() { return $this->toString(); }
}
function OrmHaxeClass_0(&$»this, &$isPrivate, &$isStatic, &$v) {
	if($isPrivate) {
		return "";
	} else {
		return "public ";
	}
}
function OrmHaxeClass_1(&$»this, &$isPrivate, &$isStatic, &$v) {
	if($isStatic) {
		return "static ";
	} else {
		return "";
	}
}
function OrmHaxeClass_2(&$»this, &$isPrivate, &$isStatic, &$v) {
	if($isStatic && $v->haxeDefVal !== null) {
		return " = " . $v->haxeDefVal;
	} else {
		return "";
	}
}
function OrmHaxeClass_3(&$»this, &$body, &$isPrivate, &$isStatic, &$name, &$retType, &$vars) {
	if($isPrivate) {
		return "";
	} else {
		return "public ";
	}
}
function OrmHaxeClass_4(&$»this, &$body, &$isPrivate, &$isStatic, &$name, &$retType, &$vars) {
	if($isStatic) {
		return "static  ";
	} else {
		return "";
	}
}
function OrmHaxeClass_5(&$body, &$isPrivate, &$isStatic, &$name, &$retType, &$vars, $v) {
	{
		$GLOBALS['%s']->push("OrmHaxeClass::addMethod@50");
		$»spos2 = $GLOBALS['%s']->length;
		{
			$»tmp = $v->haxeName . ":" . $v->haxeType . (OrmHaxeClass_10($»this, $body, $isPrivate, $isStatic, $name, $retType, $v, $vars));
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
}
function OrmHaxeClass_6(&$»this, &$clas) {
	if($»this->imports->length > 0) {
		return "\x0A\x0A";
	} else {
		return "";
	}
}
function OrmHaxeClass_7(&$»this, &$clas) {
	if($»this->baseFullClassName !== null) {
		return " extends " . $»this->baseFullClassName;
	} else {
		return "";
	}
}
function OrmHaxeClass_8(&$»this, &$clas) {
	if($»this->vars->length > 0) {
		return "\x09" . $»this->vars->join(";\x0A\x09") . ";\x0A\x0A";
	} else {
		return "";
	}
}
function OrmHaxeClass_9(&$»this, &$clas) {
	if($»this->methods->length > 0) {
		return "\x09" . $»this->methods->join("\x0A\x0A\x09") . "\x0A";
	} else {
		return "";
	}
}
function OrmHaxeClass_10(&$»this, &$body, &$isPrivate, &$isStatic, &$name, &$retType, &$v, &$vars) {
	if($v->haxeDefVal !== null) {
		return "=" . $v->haxeDefVal;
	} else {
		return "";
	}
}
