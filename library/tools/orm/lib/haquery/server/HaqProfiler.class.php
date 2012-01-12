<?php

class haquery_server_HaqProfiler {
	public function __construct() {
		;
	}
	public $blocks;
	public $opened;
	public function begin($name) {
	}
	public function end() {
	}
	public function traceResults($levelLimit) {
		if($levelLimit === null) {
			$levelLimit = 4;
		}
	}
	public function traceResultsNested($levelLimit) {
	}
	public function traceResultsSummary() {
	}
	public function traceGistogram($results) {
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
