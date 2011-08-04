<?php

class haquery_server_db_HaqDb {
	public function __construct(){}
	static $connection = null;
	static function connect($dbType, $dbServer, $dbUsername, $dbPassword, $dbDatabase) {
		$GLOBALS['%s']->push("haquery.server.db.HaqDb::connect");
		$製pos = $GLOBALS['%s']->length;
		if(haquery_server_db_HaqDb::$connection !== null) {
			$GLOBALS['%s']->pop();
			return true;
		}
		if($dbType === null) {
			$dbType = haquery_base_HaQuery::$config->dbType;
			$dbServer = haquery_base_HaQuery::$config->dbServer;
			$dbUsername = haquery_base_HaQuery::$config->dbUsername;
			$dbPassword = haquery_base_HaQuery::$config->dbPassword;
			$dbDatabase = haquery_base_HaQuery::$config->dbDatabase;
		}
		if($dbType !== null && $dbServer !== null && $dbDatabase !== null) {
			haquery_server_db_HaqDb::$connection = Type::createInstance(Type::resolveClass("haquery.server.db.HaqDbDriver_" . $dbType), new _hx_array(array($dbServer, $dbUsername, $dbPassword, $dbDatabase)));
			{
				$GLOBALS['%s']->pop();
				return true;
			}
		}
		{
			$GLOBALS['%s']->pop();
			return false;
		}
		$GLOBALS['%s']->pop();
	}
	static function query($sql) {
		$GLOBALS['%s']->push("haquery.server.db.HaqDb::query");
		$製pos = $GLOBALS['%s']->length;
		if(haquery_base_HaQuery::$config->isTraceProfiler) {
			haquery_server_HaqProfiler::begin("SQL query");
		}
		$r = haquery_server_db_HaqDb::$connection->query($sql);
		if(haquery_base_HaQuery::$config->isTraceProfiler) {
			haquery_server_HaqProfiler::end();
		}
		{
			$GLOBALS['%s']->pop();
			return $r;
		}
		$GLOBALS['%s']->pop();
	}
	static function affectedRows() {
		$GLOBALS['%s']->push("haquery.server.db.HaqDb::affectedRows");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = haquery_server_db_HaqDb::$connection->affectedRows();
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function quote($v) {
		$GLOBALS['%s']->push("haquery.server.db.HaqDb::quote");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = haquery_server_db_HaqDb::$connection->quote($v);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function lastInsertId() {
		$GLOBALS['%s']->push("haquery.server.db.HaqDb::lastInsertId");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = haquery_server_db_HaqDb::$connection->lastInsertId();
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'haquery.server.db.HaqDb'; }
}
