<?php

class TrmHaxeClass {
	public function __construct($fullClassName, $baseFullClassName) {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("TrmHaxeClass::new");
		$製pos = $GLOBALS['%s']->length;
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
		$GLOBALS['%s']->push("TrmHaxeClass::addImport");
		$製pos = $GLOBALS['%s']->length;
		$this->imports->push("import " . $packageName . ";");
		$GLOBALS['%s']->pop();
	}
	public function addVar($v, $isPrivate, $isStatic) {
		$GLOBALS['%s']->push("TrmHaxeClass::addVar");
		$製pos = $GLOBALS['%s']->length;
		if($isStatic === null) {
			$isStatic = false;
		}
		if($isPrivate === null) {
			$isPrivate = false;
		}
		$s = ((($isPrivate) ? "" : "public ")) . ((($isStatic) ? "static " : "")) . "var " . $v->name . " : " . $v->type . (TrmHaxeClass_0($this, $isPrivate, $isStatic, $v));
		$this->vars->push($s);
		$GLOBALS['%s']->pop();
	}
	public function addMethod($name, $vars, $retType, $body, $isPrivate, $isStatic) {
		$GLOBALS['%s']->push("TrmHaxeClass::addMethod");
		$製pos = $GLOBALS['%s']->length;
		if($isStatic === null) {
			$isStatic = false;
		}
		if($isPrivate === null) {
			$isPrivate = false;
		}
		$header = ((($isPrivate) ? "" : "public ")) . ((($isStatic) ? "static  " : "")) . "function " . $name . "(" . Lambda::map($vars, array(new _hx_lambda(array(&$body, &$isPrivate, &$isStatic, &$name, &$retType, &$vars), "TrmHaxeClass_1"), 'execute'))->join(", ") . ") : " . $retType;
		php_Lib::println("\x09" . $header);
		$s = $header . "\x0A" . "\x09{\x0A" . TrmTools::indent(trim($body, null), "\x09\x09") . "\x0A" . "\x09}";
		$this->methods->push($s);
		$GLOBALS['%s']->pop();
	}
	public function toString() {
		$GLOBALS['%s']->push("TrmHaxeClass::toString");
		$製pos = $GLOBALS['%s']->length;
		$clas = TrmTools::splitFullClassName($this->fullClassName);
		$s = "package " . $clas->packageName . ";\x0A" . "\x0A" . $this->imports->join("\x0A") . ((($this->imports->length > 0) ? "\x0A\x0A" : "")) . "class " . $clas->className . (TrmHaxeClass_2($this, $clas)) . "\x0A" . "{\x0A" . (TrmHaxeClass_3($this, $clas)) . (TrmHaxeClass_4($this, $clas)) . "}";
		{
			$GLOBALS['%s']->pop();
			return $s;
		}
		$GLOBALS['%s']->pop();
	}
	public function __call($m, $a) {
		if(isset($this->$m) && is_callable($this->$m))
			return call_user_func_array($this->$m, $a);
		else if(isset($this->蜿ynamics[$m]) && is_callable($this->蜿ynamics[$m]))
			return call_user_func_array($this->蜿ynamics[$m], $a);
		else if('toString' == $m)
			return $this->__toString();
		else
			throw new HException('Unable to call �'.$m.'�');
	}
	function __toString() { return $this->toString(); }
}
function TrmHaxeClass_0(&$裨his, &$isPrivate, &$isStatic, &$v) {
	$製pos = $GLOBALS['%s']->length;
	if($isStatic && $v->defVal !== null) {
		return " = " . $v->defVal;
	} else {
		return "";
	}
}
function TrmHaxeClass_1(&$body, &$isPrivate, &$isStatic, &$name, &$retType, &$vars, $v) {
	$製pos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("TrmHaxeClass::addMethod@51");
		$製pos2 = $GLOBALS['%s']->length;
		{
			$裨mp = $v->name . ":" . $v->type . (TrmHaxeClass_5($裨his, $body, $isPrivate, $isStatic, $name, $retType, $v, $vars));
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
}
function TrmHaxeClass_2(&$裨his, &$clas) {
	$製pos = $GLOBALS['%s']->length;
	if($裨his->baseFullClassName !== null) {
		return " extends " . $裨his->baseFullClassName;
	} else {
		return "";
	}
}
function TrmHaxeClass_3(&$裨his, &$clas) {
	$製pos = $GLOBALS['%s']->length;
	if($裨his->vars->length > 0) {
		return "\x09" . $裨his->vars->join(";\x0A\x09") . ";\x0A\x0A";
	} else {
		return "";
	}
}
function TrmHaxeClass_4(&$裨his, &$clas) {
	$製pos = $GLOBALS['%s']->length;
	if($裨his->methods->length > 0) {
		return "\x09" . $裨his->methods->join("\x0A\x0A\x09") . "\x0A";
	} else {
		return "";
	}
}
function TrmHaxeClass_5(&$裨his, &$body, &$isPrivate, &$isStatic, &$name, &$retType, &$v, &$vars) {
	$製pos = $GLOBALS['%s']->length;
	if($v->defVal !== null) {
		return "=" . $v->defVal;
	} else {
		return "";
	}
}
