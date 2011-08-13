<?php

class Main {
	public function __construct(){}
	static function main() {
		$GLOBALS['%s']->push("Main::main");
		$»spos = $GLOBALS['%s']->length;
		try {
			haquery_base_HaQuery::run();
		}catch(Exception $»e) {
			$_ex_ = ($»e instanceof HException) ? $»e->e : $»e;
			$e = $_ex_;
			{
				$GLOBALS['%e'] = new _hx_array(array());
				while($GLOBALS['%s']->length >= $»spos) {
					$GLOBALS['%e']->unshift($GLOBALS['%s']->pop());
				}
				$GLOBALS['%s']->push($GLOBALS['%e'][0]);
				haquery_base_HaQuery::traceException($e);
			}
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'Main'; }
}
