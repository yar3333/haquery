<?php

class Main {
	public function __construct(){}
	static function main() {
		$GLOBALS['%s']->push("Main::main");
		$»spos = $GLOBALS['%s']->length;
		$args = php_Sys::args();
		if($args->length !== 1) {
			php_Lib::println("You must specify argument: components_package.");
			php_Sys::hexit(1);
		}
		TrmGenerator::makeForComponents($args[0]);
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'Main'; }
}
