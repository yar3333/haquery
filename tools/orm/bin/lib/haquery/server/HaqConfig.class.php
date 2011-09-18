<?php

class haquery_server_HaqConfig {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("haquery.server.HaqConfig::new");
		$»spos = $GLOBALS['%s']->length;
		$this->db = _hx_anonymous(array("type" => null, "host" => null, "user" => null, "pass" => null, "database" => null));
		$this->autoSessionStart = true;
		$this->autoDatabaseConnect = true;
		$this->sqlTraceLevel = 1;
		$this->isTraceComponent = false;
		$this->isTraceProfiler = false;
		$this->filterTracesByIP = "";
		$this->custom = null;
		$this->componentsFolders = new _hx_array(array("haquery/components"));
		$this->layout = null;
		$GLOBALS['%s']->pop();
	}}
	public $db;
	public $autoSessionStart;
	public $autoDatabaseConnect;
	public $sqlTraceLevel;
	public $isTraceComponent;
	public $isTraceProfiler;
	public $filterTracesByIP;
	public $custom;
	public $componentsFolders;
	public $layout;
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
	function __toString() { return 'haquery.server.HaqConfig'; }
}
