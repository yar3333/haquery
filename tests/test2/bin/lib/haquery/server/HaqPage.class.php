<?php

class haquery_server_HaqPage extends haquery_server_HaqComponent {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("haquery.server.HaqPage::new");
		$»spos = $GLOBALS['%s']->length;
		parent::__construct();
		$this->contentType = "text/html; charset=utf-8";
		$GLOBALS['%s']->pop();
	}}
	public $contentType;
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
	function __toString() { return 'haquery.server.HaqPage'; }
}
