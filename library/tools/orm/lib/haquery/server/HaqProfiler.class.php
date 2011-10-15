<?php

class haquery_server_HaqProfiler {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("haquery.server.HaqProfiler::new");
		$»spos = $GLOBALS['%s']->length;
		$GLOBALS['%s']->pop();
	}}
	public $blocks;
	public $opened;
	public function begin($name) {
		$GLOBALS['%s']->push("haquery.server.HaqProfiler::begin");
		$»spos = $GLOBALS['%s']->length;
		$GLOBALS['%s']->pop();
	}
	public function end() {
		$GLOBALS['%s']->push("haquery.server.HaqProfiler::end");
		$»spos = $GLOBALS['%s']->length;
		$GLOBALS['%s']->pop();
	}
	public function traceResults($levelLimit) {
		$GLOBALS['%s']->push("haquery.server.HaqProfiler::traceResults");
		$»spos = $GLOBALS['%s']->length;
		if($levelLimit === null) {
			$levelLimit = 4;
		}
		$GLOBALS['%s']->pop();
	}
	public function traceResultsNested($levelLimit) {
		$GLOBALS['%s']->push("haquery.server.HaqProfiler::traceResultsNested");
		$»spos = $GLOBALS['%s']->length;
		$GLOBALS['%s']->pop();
	}
	public function traceResultsSummary() {
		$GLOBALS['%s']->push("haquery.server.HaqProfiler::traceResultsSummary");
		$»spos = $GLOBALS['%s']->length;
		$GLOBALS['%s']->pop();
	}
	public function traceGistogram($results) {
		$GLOBALS['%s']->push("haquery.server.HaqProfiler::traceGistogram");
		$»spos = $GLOBALS['%s']->length;
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
	static $file = "temp/profiler.data";
	static $traceWidth = 120;
	function __toString() { return 'haquery.server.HaqProfiler'; }
}
