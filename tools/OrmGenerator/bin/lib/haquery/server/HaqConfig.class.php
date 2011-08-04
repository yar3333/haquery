<?php

class haquery_server_HaqConfig {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("haquery.server.HaqConfig::new");
		$»spos = $GLOBALS['%s']->length;
		$this->dbType = "";
		$this->dbServer = "";
		$this->dbUsername = "";
		$this->dbPassword = "";
		$this->dbDatabase = "";
		$this->autoSessionStart = true;
		$this->autoDatabaseConnect = true;
		$this->sqlTraceLevel = 1;
		$this->stopOnSqlError = true;
		$this->isTraceComponent = false;
		$this->isTraceProfiler = false;
		$this->traceFilter_IP = "";
		$this->custom = null;
		$this->consts = new Hash();
		$this->componentsFolders = new _hx_array(array());
		$GLOBALS['%s']->pop();
	}}
	public $dbType;
	public $dbServer;
	public $dbUsername;
	public $dbPassword;
	public $dbDatabase;
	public $autoSessionStart;
	public $autoDatabaseConnect;
	public $sqlTraceLevel;
	public $stopOnSqlError;
	public $isTraceComponent;
	public $isTraceProfiler;
	public $traceFilter_IP;
	public $custom;
	public $consts;
	public $componentsFolders;
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
