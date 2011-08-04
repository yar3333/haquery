<?php

class haquery_base_HaqEvent {
	public function __construct($component, $name) {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("haquery.base.HaqEvent::new");
		$»spos = $GLOBALS['%s']->length;
		$this->handlers = new _hx_array(array());
		$this->component = $component;
		$this->name = $name;
		$GLOBALS['%s']->pop();
	}}
	public $handlers;
	public $component;
	public $name;
	public function bind($obj, $func) {
		$GLOBALS['%s']->push("haquery.base.HaqEvent::bind");
		$»spos = $GLOBALS['%s']->length;
		$this->handlers->push(_hx_anonymous(array("o" => $obj, "f" => $func)));
		{
			$GLOBALS['%s']->pop();
			return $this;
		}
		$GLOBALS['%s']->pop();
	}
	public function call($params) {
		$GLOBALS['%s']->push("haquery.base.HaqEvent::call");
		$»spos = $GLOBALS['%s']->length;
		$i = $this->handlers->length - 1;
		while($i >= 0) {
			$obj = _hx_array_get($this->handlers, $i)->o;
			$func = (isset(_hx_array_get($this->handlers, $i)->f) ? _hx_array_get($this->handlers, $i)->f: array($this->handlers[$i], "f"));
			$r = Reflect::callMethod($obj, $func, $params);
			if($r === false) {
				$GLOBALS['%s']->pop();
				return false;
			}
			$i--;
			unset($r,$obj,$func);
		}
		{
			$GLOBALS['%s']->pop();
			return true;
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
	function __toString() { return 'haquery.base.HaqEvent'; }
}
