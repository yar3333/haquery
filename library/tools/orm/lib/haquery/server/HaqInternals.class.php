<?php

class haquery_server_HaqInternals {
	public function __construct(){}
	static $ajaxResponse = "";
	static function addAjaxResponse($jsCode) {
		haquery_server_HaqInternals::$ajaxResponse .= $jsCode . "\x0A";
	}
	static function getAjaxResponse() {
		return haquery_server_HaqInternals::$ajaxResponse;
	}
	function __toString() { return 'haquery.server.HaqInternals'; }
}
