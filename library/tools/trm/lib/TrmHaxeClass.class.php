<?php

class TrmHaxeClass {
	public function __construct($fullClassName, $baseFullClassName) {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("TrmHaxeClass::new");
		$»spos = $GLOBALS['%s']->length;
		$this->fullClassName = $fullClassName;
		$this->baseFullClassName = $baseFullClassName;
		$this->imports = new _hx_array(array());
		$this->vars = new _hx_array(array());
		$this->methods = new _hx_array(array());
		$this->customs = new _hx_array(array());
		$GLOBALS['%s']->pop();
	}}
	public $fullClassName;
	public $baseFullClassName;
	public $imports;
	public $vars;
	public $methods;
	public $customs;
	public function addImport($packageName) {
		$GLOBALS['%s']->push("TrmHaxeClass::addImport");
		$»spos = $GLOBALS['%s']->length;
		$this->imports->push("import " . $packageName . ";");
		$GLOBALS['%s']->pop();
	}
	public function addVar($v, $isPrivate, $isStatic) {
		$GLOBALS['%s']->push("TrmHaxeClass::addVar");
		$»spos = $GLOBALS['%s']->length;
		if($isStatic === null) {
			$isStatic = false;
		}
		if($isPrivate === null) {
			$isPrivate = false;
		}
		$s = ((($isPrivate) ? "" : "public ")) . ((($isStatic) ? "static " : "")) . "var " . $v->name . " : " . $v->type . (TrmHaxeClass_0($this, $isPrivate, $isStatic, $v)) . ";";
		$this->vars->push($s);
		$GLOBALS['%s']->pop();
	}
	public function addVarGetter($v, $isPrivate, $isStatic, $isInline) {
		$GLOBALS['%s']->push("TrmHaxeClass::addVarGetter");
		$»spos = $GLOBALS['%s']->length;
		if($isInline === null) {
			$isInline = false;
		}
		if($isStatic === null) {
			$isStatic = false;
		}
		if($isPrivate === null) {
			$isPrivate = false;
		}
		$s = "\x0A\x09" . ((($isPrivate) ? "" : "public ")) . ((($isStatic) ? "static " : "")) . "var " . $v->name . "(" . $v->name . "_getter, null)" . " : " . $v->type . ";\x0A";
		$s .= ((($isInline) ? "\x09inline " : "\x09")) . "function " . $v->name . "_getter() : " . $v->type . "\x0A" . "\x09{\x0A" . TrmTools::indent(trim($v->body, null), "\x09\x09") . "\x0A" . "\x09}";
		$this->vars->push($s);
		$GLOBALS['%s']->pop();
	}
	public function addMethod($name, $vars, $retType, $body, $isPrivate, $isStatic) {
		$GLOBALS['%s']->push("TrmHaxeClass::addMethod");
		$»spos = $GLOBALS['%s']->length;
		if($isStatic === null) {
			$isStatic = false;
		}
		if($isPrivate === null) {
			$isPrivate = false;
		}
		$header = ((($isPrivate) ? "" : "public ")) . ((($isStatic) ? "static  " : "")) . "function " . $name . "(" . Lambda::map($vars, array(new _hx_lambda(array(&$body, &$isPrivate, &$isStatic, &$name, &$retType, &$vars), "TrmHaxeClass_1"), 'execute'))->join(", ") . ") : " . $retType;
		$s = $header . "\x0A" . "\x09{\x0A" . TrmTools::indent(trim($body, null), "\x09\x09") . "\x0A" . "\x09}";
		$this->methods->push($s);
		$GLOBALS['%s']->pop();
	}
	public function addCustom($code) {
		$GLOBALS['%s']->push("TrmHaxeClass::addCustom");
		$»spos = $GLOBALS['%s']->length;
		$this->customs->push($code);
		$GLOBALS['%s']->pop();
	}
	public function toString() {
		$GLOBALS['%s']->push("TrmHaxeClass::toString");
		$»spos = $GLOBALS['%s']->length;
		$clas = TrmTools::splitFullClassName($this->fullClassName);
		$s = "package " . $clas->packageName . ";\x0A" . "\x0A" . $this->imports->join("\x0A") . ((($this->imports->length > 0) ? "\x0A\x0A" : "")) . "class " . $clas->className . (TrmHaxeClass_2($this, $clas)) . "\x0A" . "{\x0A" . (TrmHaxeClass_3($this, $clas)) . (TrmHaxeClass_4($this, $clas)) . (TrmHaxeClass_5($this, $clas)) . "}";
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
function TrmHaxeClass_0(&$»this, &$isPrivate, &$isStatic, &$v) {
	$»spos = $GLOBALS['%s']->length;
	if($isStatic && $v->defVal !== null) {
		return " = " . $v->defVal;
	} else {
		return "";
	}
}
function TrmHaxeClass_1(&$body, &$isPrivate, &$isStatic, &$name, &$retType, &$vars, $v) {
	$»spos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("TrmHaxeClass::addMethod@78");
		$»spos2 = $GLOBALS['%s']->length;
		{
			$»tmp = $v->name . ":" . $v->type . (TrmHaxeClass_6($»this, $body, $isPrivate, $isStatic, $name, $retType, $v, $vars));
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
}
function TrmHaxeClass_2(&$»this, &$clas) {
	$»spos = $GLOBALS['%s']->length;
	if($»this->baseFullClassName !== null) {
		return " extends " . $»this->baseFullClassName;
	} else {
		return "";
	}
}
function TrmHaxeClass_3(&$»this, &$clas) {
	$»spos = $GLOBALS['%s']->length;
	if($»this->vars->length > 0) {
		return "\x09" . $»this->vars->join("\x0A\x09") . "\x0A\x0A";
	} else {
		return "";
	}
}
function TrmHaxeClass_4(&$»this, &$clas) {
	$»spos = $GLOBALS['%s']->length;
	if($»this->methods->length > 0) {
		return "\x09" . $»this->methods->join("\x0A\x0A\x09") . "\x0A";
	} else {
		return "";
	}
}
function TrmHaxeClass_5(&$»this, &$clas) {
	$»spos = $GLOBALS['%s']->length;
	if($»this->customs->length > 0) {
		return "\x09" . $»this->customs->join("\x0A\x0A\x09") . "\x0A";
	} else {
		return "";
	}
}
function TrmHaxeClass_6(&$»this, &$body, &$isPrivate, &$isStatic, &$name, &$retType, &$v, &$vars) {
	$»spos = $GLOBALS['%s']->length;
	if($v->defVal !== null) {
		return "=" . $v->defVal;
	} else {
		return "";
	}
}
