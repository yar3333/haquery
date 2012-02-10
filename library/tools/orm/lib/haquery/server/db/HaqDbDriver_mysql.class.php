<?php

class haquery_server_db_HaqDbDriver_mysql implements haquery_server_db_HaqDbDriver{
	public function __construct($host, $user, $pass, $database) {
		if(!php_Boot::$skip_constructor) {
		$this->database = $database;
		$this->connection = php_db_Mysql::connect(_hx_anonymous(array("host" => $host, "user" => $user, "pass" => $pass, "database" => $database, "port" => 0, "socket" => "")));
		$this->connection->request("set names utf8");
		$this->connection->request("set character_set_client='utf8'");
		$this->connection->request("set character_set_results='utf8'");
		$this->connection->request("set collation_connection='utf8_general_ci'");
	}}
	public $connection;
	public $database;
	public function query($sql) {
		if(haquery_server_Lib::$config->sqlTraceLevel >= 2) {
			haxe_Log::trace("SQL QUERY: " . $sql, _hx_anonymous(array("fileName" => "HaqDbDriver_mysql.hx", "lineNumber" => 27, "className" => "haquery.server.db.HaqDbDriver_mysql", "methodName" => "query")));
		}
		$r = $this->connection->request($sql);
		$errno = mysql_errno();
		if($errno !== 0) {
			throw new HException("sql query error:\x0A" . "SQL QUERY: " . $sql . "\x0A" . "SQL RESULT: " . $this->affectedRows() . " rows affected, error code = " . $errno . " (" . $this->getLastErrorMessage() . ").");
		}
		if(haquery_server_Lib::$config->sqlTraceLevel > 0) {
			if(haquery_server_Lib::$config->sqlTraceLevel === 1 && $errno !== 0) {
				haxe_Log::trace("SQL QUERY: " . $sql, _hx_anonymous(array("fileName" => "HaqDbDriver_mysql.hx", "lineNumber" => 38, "className" => "haquery.server.db.HaqDbDriver_mysql", "methodName" => "query")));
			}
			if(haquery_server_Lib::$config->sqlTraceLevel >= 3 || $errno !== 0) {
				haxe_Log::trace("SQL RESULT: " . $this->affectedRows() . " rows affected, error code = " . $errno . " (" . $this->getLastErrorMessage() . ").", _hx_anonymous(array("fileName" => "HaqDbDriver_mysql.hx", "lineNumber" => 41, "className" => "haquery.server.db.HaqDbDriver_mysql", "methodName" => "query")));
			}
		}
		return $r;
	}
	public function affectedRows() {
		return mysql_affected_rows();
	}
	public function getLastErrorMessage() {
		return mysql_error();
	}
	public function getTables() {
		$r = new _hx_array(array());
		$rows = $this->query("SHOW TABLES FROM `" . $this->database . "`");
		$»it = $rows;
		while($»it->hasNext()) {
			$row = $»it->next();
			$fields = Reflect::fields($row);
			$r->push(Reflect::field($row, $fields[0]));
			unset($fields);
		}
		return $r;
	}
	public function getFields($table) {
		$r = new _hx_array(array());
		$rows = $this->query("SHOW COLUMNS FROM `" . $table . "`");
		$»it = $rows;
		while($»it->hasNext()) {
			$row = $»it->next();
			$fields = Reflect::fields($row);
			$r->push(_hx_anonymous(array("name" => $row->Field, "type" => Reflect::field($row, "Type"), "isNull" => _hx_equal(Reflect::field($row, "Null"), "YES"), "isKey" => $row->Key === "PRI", "isAutoInc" => $row->Extra === "auto_increment")));
			unset($fields);
		}
		return $r;
	}
	public function quote($v) {
		$»t = (Type::typeof($v));
		switch($»t->index) {
		case 6:
		$cls = $»t->params[0];
		{
			if($cls === _hx_qtype("String")) {
				return $this->connection->quote($v);
			} else {
				if($cls === _hx_qtype("Date")) {
					$date = $v;
					return "'" . $date->toString() . "'";
				}
			}
		}break;
		case 1:
		{
			return Std::string($v);
		}break;
		case 2:
		{
			return Std::string($v);
		}break;
		case 0:
		{
			return "NULL";
		}break;
		case 3:
		{
			return (($v) ? "1" : "0");
		}break;
		default:{
		}break;
		}
		throw new HException("Unsupported parameter type '" . Type::getClassName(Type::getClass($v)) . "'.");
	}
	public function lastInsertId() {
		return $this->connection->lastInsertId();
	}
	public function getForeignKeys($table) {
		$sql = "\x0D\x0A  SELECT\x0D\x0A   u.table_schema AS 'schema',\x0D\x0A   u.table_name AS 'table',\x0D\x0A   u.column_name AS 'key',\x0D\x0A   u.referenced_table_schema AS 'parentSchema',\x0D\x0A   u.referenced_table_name AS 'parentTable',\x0D\x0A   u.referenced_column_name AS 'parentKey'\x0D\x0A  FROM information_schema.table_constraints AS c\x0D\x0A  INNER JOIN information_schema.key_column_usage AS u\x0D\x0A  USING( constraint_schema, constraint_name )\x0D\x0A  WHERE c.constraint_type = 'FOREIGN KEY'\x0D\x0A    AND c.table_schema = '" . $this->database . "'\x0D\x0A    AND u.table_name = '" . $table . "'\x0D\x0A  ORDER BY u.table_schema, u.table_name, u.column_name;\x0D\x0A";
		$rows = $this->query($sql);
		$r = new _hx_array(array());
		$»it = $rows;
		while($»it->hasNext()) {
			$row = $»it->next();
			$r->push($row);
		}
		return $r;
	}
	public function getUniques($table) {
		$rows = $this->query("SHOW INDEX FROM `" . $table . "` WHERE Non_unique=0 AND Key_name<>'PRIMARY'");
		$r = new Hash();
		$»it = $rows;
		while($»it->hasNext()) {
			$row = $»it->next();
			$key = $row->Key_name;
			if(!$r->exists($key)) {
				$r->set($key, new _hx_array(array()));
			}
			$r->get($key)->push($row->Column_name);
			unset($key);
		}
		return $r;
	}
	public function __call($m, $a) {
		if(isset($this->$m) && is_callable($this->$m))
			return call_user_func_array($this->$m, $a);
		else if(isset($this->»dynamics[$m]) && is_callable($this->»dynamics[$m]))
			return call_user_func_array($this->»dynamics[$m], $a);
		else if('toString' == $m)
			return $this->__toString();
		else
			throw new HException('Unable to call «'.$m.'»');
	}
	function __toString() { return 'haquery.server.db.HaqDbDriver_mysql'; }
}
