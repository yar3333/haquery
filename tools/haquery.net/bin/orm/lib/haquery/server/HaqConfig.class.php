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
		$this->filterTracesByIP = "";
		$this->customData = new Hash();
		$this->componentsFolders = new _hx_array(array("haquery/components"));
		$this->layout = null;
		$GLOBALS['%s']->pop();
	}}
	public $db;
	public $autoSessionStart;
	public $autoDatabaseConnect;
	public $sqlTraceLevel;
	public $isTraceComponent;
	public $filterTracesByIP;
	public $customData;
	public $componentsFolders;
	public function addComponentsFolder($path) {
		$GLOBALS['%s']->push("haquery.server.HaqConfig::addComponentsFolder");
		$»spos = $GLOBALS['%s']->length;
		$this->componentsFolders->push(rtrim(str_replace("\\", "/", $path), "/"));
		$GLOBALS['%s']->pop();
	}
	public function getComponentsFolders() {
		$GLOBALS['%s']->push("haquery.server.HaqConfig::getComponentsFolders");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $this->componentsFolders;
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
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
