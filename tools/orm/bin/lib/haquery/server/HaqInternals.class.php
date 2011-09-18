<?php

class haquery_server_HaqInternals {
	public function __construct(){}
	static $DELIMITER = "-";
	static $ajaxAnswer = "";
	static function addAjaxAnswer($jsCode) {
		$GLOBALS['%s']->push("haquery.server.HaqInternals::addAjaxAnswer");
		$»spos = $GLOBALS['%s']->length;
		haquery_server_HaqInternals::$ajaxAnswer .= $jsCode . "\x0A";
		$GLOBALS['%s']->pop();
	}
	static function getAjaxAnswer() {
		$GLOBALS['%s']->push("haquery.server.HaqInternals::getAjaxAnswer");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = haquery_server_HaqInternals::$ajaxAnswer;
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'haquery.server.HaqInternals'; }
}
