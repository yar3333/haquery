<?php

class php_db__Mysql_MysqlConnection implements sys_db_Connection{
	public function __construct($c) {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("php.db._Mysql.MysqlConnection::new");
		$»spos = $GLOBALS['%s']->length;
		$this->c = $c;
		$GLOBALS['%s']->pop();
	}}
	public $c;
	public function close() {
		$GLOBALS['%s']->push("php.db._Mysql.MysqlConnection::close");
		$»spos = $GLOBALS['%s']->length;
		mysql_close($this->c);
		unset($this->c);
		$GLOBALS['%s']->pop();
	}
	public function request($s) {
		$GLOBALS['%s']->push("php.db._Mysql.MysqlConnection::request");
		$»spos = $GLOBALS['%s']->length;
		$h = mysql_query($s, $this->c);
		if(($h === false)) {
			throw new HException("Error while executing " . $s . " (" . (mysql_error($this->c) . ")"));
		}
		{
			$»tmp = new php_db__Mysql_MysqlResultSet($h, $this->c);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function escape($s) {
		$GLOBALS['%s']->push("php.db._Mysql.MysqlConnection::escape");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = mysql_real_escape_string($s, $this->c);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function quote($s) {
		$GLOBALS['%s']->push("php.db._Mysql.MysqlConnection::quote");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = "'" . (mysql_real_escape_string($s, $this->c) . "'");
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function addValue($s, $v) {
		$GLOBALS['%s']->push("php.db._Mysql.MysqlConnection::addValue");
		$»spos = $GLOBALS['%s']->length;
		if(is_int($v) || is_null($v)) {
			$x = $v;
			if(is_null($x)) {
				$x = "null";
			} else {
				if(is_bool($x)) {
					$x = (($x) ? "true" : "false");
				}
			}
			$s->b .= $x;
		} else {
			if(is_bool($v)) {
				$x = (($v) ? 1 : 0);
				if(is_null($x)) {
					$x = "null";
				} else {
					if(is_bool($x)) {
						$x = (($x) ? "true" : "false");
					}
				}
				$s->b .= $x;
			} else {
				$x = $this->quote(Std::string($v));
				if(is_null($x)) {
					$x = "null";
				} else {
					if(is_bool($x)) {
						$x = (($x) ? "true" : "false");
					}
				}
				$s->b .= $x;
			}
		}
		$GLOBALS['%s']->pop();
	}
	public function lastInsertId() {
		$GLOBALS['%s']->push("php.db._Mysql.MysqlConnection::lastInsertId");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = mysql_insert_id($this->c);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function dbName() {
		$GLOBALS['%s']->push("php.db._Mysql.MysqlConnection::dbName");
		$»spos = $GLOBALS['%s']->length;
		{
			$GLOBALS['%s']->pop();
			return "MySQL";
		}
		$GLOBALS['%s']->pop();
	}
	public function startTransaction() {
		$GLOBALS['%s']->push("php.db._Mysql.MysqlConnection::startTransaction");
		$»spos = $GLOBALS['%s']->length;
		$this->request("START TRANSACTION");
		$GLOBALS['%s']->pop();
	}
	public function commit() {
		$GLOBALS['%s']->push("php.db._Mysql.MysqlConnection::commit");
		$»spos = $GLOBALS['%s']->length;
		$this->request("COMMIT");
		$GLOBALS['%s']->pop();
	}
	public function rollback() {
		$GLOBALS['%s']->push("php.db._Mysql.MysqlConnection::rollback");
		$»spos = $GLOBALS['%s']->length;
		$this->request("ROLLBACK");
		$GLOBALS['%s']->pop();
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
	function __toString() { return 'php.db._Mysql.MysqlConnection'; }
}
