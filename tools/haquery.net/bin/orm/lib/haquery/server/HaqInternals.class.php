<?php

class haquery_server_HaqInternals {
	public function __construct(){}
	static $DELIMITER = "-";
	static $ajaxResponse = "";
	static function addAjaxResponse($jsCode) {
		$GLOBALS['%s']->push("haquery.server.HaqInternals::addAjaxResponse");
		$»spos = $GLOBALS['%s']->length;
		haquery_server_HaqInternals::$ajaxResponse .= $jsCode . "\x0A";
		$GLOBALS['%s']->pop();
	}
	static function getAjaxResponse() {
		$GLOBALS['%s']->push("haquery.server.HaqInternals::getAjaxResponse");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = haquery_server_HaqInternals::$ajaxResponse;
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'haquery.server.HaqInternals'; }
}
