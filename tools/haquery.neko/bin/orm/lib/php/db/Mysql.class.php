<?php

class php_db_Mysql {
	public function __construct(){}
	static function connect($params) {
		$GLOBALS['%s']->push("php.db.Mysql::connect");
		$»spos = $GLOBALS['%s']->length;
		$c = mysql_connect($params->host . (php_db_Mysql_0($params)) . (php_db_Mysql_1($params)), $params->user, $params->pass);
		if(!mysql_select_db($params->database, $c)) {
			throw new HException("Unable to connect to " . $params->database);
		}
		{
			$»tmp = new php_db__Mysql_MysqlConnection($c);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'php.db.Mysql'; }
}
function php_db_Mysql_0(&$params) {
	$»spos = $GLOBALS['%s']->length;
	if($params->port === null) {
		return "";
	} else {
		return ":" . $params->port;
	}
}
function php_db_Mysql_1(&$params) {
	$»spos = $GLOBALS['%s']->length;
	if($params->socket === null) {
		return "";
	} else {
		return ":" . $params->socket;
	}
}
