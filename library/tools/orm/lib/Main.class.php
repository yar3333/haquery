<?php

class Main {
	public function __construct(){}
	static function main() {
		$args = php_Sys::args();
		if($args->length !== 2) {
			php_Lib::println("You must specify arguments: connection_string path_to_src.");
			php_Sys::hexit(1);
		}
		$re = new EReg("^([a-z]+)\\://([_a-zA-Z0-9]+)\\:(.+?)@([_a-zA-Z0-9]+)/([_a-zA-Z0-9]+)\$", "");
		if(!$re->match($args[0])) {
			php_Lib::println("Connection string example: 'mysql://root:123456@localhost/test'.");
			php_Sys::hexit(1);
		}
		if(!is_dir($args[1])) {
			php_Lib::println("Directory " . $args[1] . " not found.");
			php_Sys::hexit(1);
		}
		haquery_server_db_HaqDb::connect(_hx_anonymous(array("type" => $re->matched(1), "user" => $re->matched(2), "pass" => $re->matched(3), "host" => $re->matched(4), "database" => $re->matched(5))));
		OrmGenerator::make($args[1]);
	}
	function __toString() { return 'Main'; }
}
