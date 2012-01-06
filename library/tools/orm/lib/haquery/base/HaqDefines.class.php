<?php

class haquery_base_HaqDefines {
	public function __construct(){}
	static $VERSION = 2.6;
	static $folders;
	static $DELIMITER = "-";
	function __toString() { return 'haquery.base.HaqDefines'; }
}
haquery_base_HaqDefines::$folders = _hx_anonymous(array("pages" => "pages", "support" => "support", "temp" => "temp"));
