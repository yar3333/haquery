<?php

class haquery_server_db_HaqDb {
	public function __construct(){}
	static $connection = null;
	static function connect($params) {
		$GLOBALS['%s']->push("haquery.server.db.HaqDb::connect");
		$�spos = $GLOBALS['%s']->length;
		if(haquery_server_db_HaqDb::$connection !== null) {
			$GLOBALS['%s']->pop();
			return true;
		}
		null;
		haquery_server_db_HaqDb::$connection = Type::createInstance(Type::resolveClass("haquery.server.db.HaqDbDriver_" . $params->type), new _hx_array(array($params->host, $params->user, $params->pass, $params->database)));
		null;
		{
			$GLOBALS['%s']->pop();
			return true;
		}
		$GLOBALS['%s']->pop();
	}
	static function query($sql) {
		$GLOBALS['%s']->push("haquery.server.db.HaqDb::query");
		$�spos = $GLOBALS['%s']->length;
		null;
		$r = haquery_server_db_HaqDb::$connection->query($sql);
		null;
		{
			$GLOBALS['%s']->pop();
			return $r;
		}
		$GLOBALS['%s']->pop();
	}
	static function affectedRows() {
		$GLOBALS['%s']->push("haquery.server.db.HaqDb::affectedRows");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = haquery_server_db_HaqDb::$connection->affectedRows();
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function quote($v) {
		$GLOBALS['%s']->push("haquery.server.db.HaqDb::quote");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = haquery_server_db_HaqDb::$connection->quote($v);
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function lastInsertId() {
		$GLOBALS['%s']->push("haquery.server.db.HaqDb::lastInsertId");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = haquery_server_db_HaqDb::$connection->lastInsertId();
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'haquery.server.db.HaqDb'; }
}
