<?php

class haquery_server_HaqProfiler {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("haquery.server.HaqProfiler::new");
		$製pos = $GLOBALS['%s']->length;
		$GLOBALS['%s']->pop();
	}}
	public $blocks;
	public $opened;
	public function begin($name) {
		$GLOBALS['%s']->push("haquery.server.HaqProfiler::begin");
		$製pos = $GLOBALS['%s']->length;
		$GLOBALS['%s']->pop();
	}
	public function end() {
		$GLOBALS['%s']->push("haquery.server.HaqProfiler::end");
		$製pos = $GLOBALS['%s']->length;
		$GLOBALS['%s']->pop();
	}
	public function traceResults($levelLimit) {
		$GLOBALS['%s']->push("haquery.server.HaqProfiler::traceResults");
		$製pos = $GLOBALS['%s']->length;
		if($levelLimit === null) {
			$levelLimit = 4;
		}
		$GLOBALS['%s']->pop();
	}
	public function traceResultsNested($levelLimit) {
		$GLOBALS['%s']->push("haquery.server.HaqProfiler::traceResultsNested");
		$製pos = $GLOBALS['%s']->length;
		$GLOBALS['%s']->pop();
	}
	public function traceResultsSummary() {
		$GLOBALS['%s']->push("haquery.server.HaqProfiler::traceResultsSummary");
		$製pos = $GLOBALS['%s']->length;
		$GLOBALS['%s']->pop();
	}
	public function traceGistogram($results) {
		$GLOBALS['%s']->push("haquery.server.HaqProfiler::traceGistogram");
		$製pos = $GLOBALS['%s']->length;
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
	static $file = "temp/profiler.data";
	static $traceWidth = 120;
	function __toString() { return 'haquery.server.HaqProfiler'; }
}
