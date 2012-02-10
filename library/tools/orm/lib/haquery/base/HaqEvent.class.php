<?php

class haquery_base_HaqEvent {
	public function __construct($component, $name) {
		if(!php_Boot::$skip_constructor) {
		$this->handlers = new _hx_array(array());
		$this->component = $component;
		$this->name = $name;
	}}
	public $handlers;
	public $component;
	public $name;
	public function bind($obj, $func) {
		$this->handlers->push(_hx_anonymous(array("o" => $obj, "f" => $func)));
		return $this;
	}
	public function call($params) {
		if($params === null) {
			$params = new _hx_array(array());
		}
		$i = $this->handlers->length - 1;
		while($i >= 0) {
			$obj = _hx_array_get($this->handlers, $i)->o;
			$func = (isset(_hx_array_get($this->handlers, $i)->f) ? _hx_array_get($this->handlers, $i)->f: array($this->handlers[$i], "f"));
			$r = Reflect::callMethod($obj, $func, _hx_deref((new _hx_array(array($this->component->parent))))->concat($params));
			if($r === false) {
				return false;
			}
			$i--;
			unset($r,$obj,$func);
		}
		return true;
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
