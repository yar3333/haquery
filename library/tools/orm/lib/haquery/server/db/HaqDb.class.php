<?php

class haquery_server_db_HaqDb {
	public function __construct(){}
	static $connection = null;
	static function connect($params) {
		if(haquery_server_db_HaqDb::$connection !== null) {
			return true;
		}
		null;
		haquery_server_db_HaqDb::$connection = Type::createInstance(Type::resolveClass("haquery.server.db.HaqDbDriver_" . $params->type), new _hx_array(array($params->host, $params->user, $params->pass, $params->database)));
		null;
		return true;
	}
	static function query($sql) {
		null;
		$r = haquery_server_db_HaqDb::$connection->query($sql);
		null;
		return $r;
	}
	static function affectedRows() {
		return haquery_server_db_HaqDb::$connection->affectedRows();
	}
	static function quote($v) {
		return haquery_server_db_HaqDb::$connection->quote($v);
	}
	static function lastInsertId() {
		return haquery_server_db_HaqDb::$connection->lastInsertId();
	}
	function __toString() { return 'haquery.server.db.HaqDb'; }
}
