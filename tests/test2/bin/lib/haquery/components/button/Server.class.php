<?php

class haquery_components_button_Server extends haquery_server_HaqComponent {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("haquery.components.button.Server::new");
		$»spos = $GLOBALS['%s']->length;
		parent::__construct();
		$GLOBALS['%s']->pop();
	}}
	public $event_click;
	public $text;
	public $clas;
	public $style;
	public $hidden;
	public function preRender() {
		$GLOBALS['%s']->push("haquery.components.button.Server::preRender");
		$»spos = $GLOBALS['%s']->length;
		if($this->text !== null) {
			$this->q("#b td")->html($this->text, null);
		}
		if($this->clas !== null) {
			$this->q("#b")->addClass($this->clas);
		}
		if($this->style !== null) {
			$this->q("#b")->attr("style", $this->style);
		}
		if($this->hidden) {
			$this->q("#b")->css("visibility", "hidden");
		}
		$GLOBALS['%s']->pop();
	}
	public function b_click() {
		$GLOBALS['%s']->push("haquery.components.button.Server::b_click");
		$»spos = $GLOBALS['%s']->length;
		$this->event_click->call(null);
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
	function __toString() { return 'haquery.components.button.Server'; }
}
