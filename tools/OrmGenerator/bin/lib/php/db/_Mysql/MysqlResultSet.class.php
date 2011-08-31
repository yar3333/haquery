<?php

class php_db__Mysql_MysqlResultSet implements php_db_ResultSet{
	public function __construct($r, $c) {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("php.db._Mysql.MysqlResultSet::new");
		$»spos = $GLOBALS['%s']->length;
		$this->__r = $r;
		$this->__c = $c;
		$GLOBALS['%s']->pop();
	}}
	public $length;
	public $nfields;
	public $__r;
	public $__c;
	public $cache;
	public function getLength() {
		$GLOBALS['%s']->push("php.db._Mysql.MysqlResultSet::getLength");
		$»spos = $GLOBALS['%s']->length;
		if($this->__r === true) {
			$»tmp = mysql_affected_rows($this->__c);
			$GLOBALS['%s']->pop();
			return $»tmp;
		} else {
			if($this->__r === false) {
				$GLOBALS['%s']->pop();
				return 0;
			}
		}
		{
			$»tmp = mysql_num_rows($this->__r);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public $_nfields;
	public function getNFields() {
		$GLOBALS['%s']->push("php.db._Mysql.MysqlResultSet::getNFields");
		$»spos = $GLOBALS['%s']->length;
		if($this->_nfields === null) {
			$this->_nfields = mysql_num_fields($this->__r);
		}
		{
			$»tmp = $this->_nfields;
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public $_fieldsDesc;
	public function getFieldsDescription() {
		$GLOBALS['%s']->push("php.db._Mysql.MysqlResultSet::getFieldsDescription");
		$»spos = $GLOBALS['%s']->length;
		if($this->_fieldsDesc === null) {
			$this->_fieldsDesc = new _hx_array(array());
			{
				$_g1 = 0; $_g = $this->getNFields();
				while($_g1 < $_g) {
					$i = $_g1++;
					$item = _hx_anonymous(array("name" => mysql_field_name($this->__r, $i), "type" => mysql_field_type($this->__r, $i)));
					$this->_fieldsDesc->push($item);
					unset($item,$i);
				}
			}
		}
		{
			$»tmp = $this->_fieldsDesc;
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function convert($v, $type) {
		$GLOBALS['%s']->push("php.db._Mysql.MysqlResultSet::convert");
		$»spos = $GLOBALS['%s']->length;
		if($v === null) {
			$GLOBALS['%s']->pop();
			return $v;
		}
		switch($type) {
		case "int":case "year":{
			$»tmp = intval($v);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}break;
		case "real":{
			$»tmp = floatval($v);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}break;
		case "datetime":case "date":{
			$»tmp = Date::fromString($v);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}break;
		default:{
			$GLOBALS['%s']->pop();
			return $v;
		}break;
		}
		$GLOBALS['%s']->pop();
	}
	public function hasNext() {
		$GLOBALS['%s']->push("php.db._Mysql.MysqlResultSet::hasNext");
		$»spos = $GLOBALS['%s']->length;
		if(_hx_field($this, "cache") === null) {
			$this->cache = $this->next();
		}
		{
			$»tmp = _hx_field($this, "cache") !== null;
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public $cRow;
	public function fetchRow() {
		$GLOBALS['%s']->push("php.db._Mysql.MysqlResultSet::fetchRow");
		$»spos = $GLOBALS['%s']->length;
		$this->cRow = mysql_fetch_array($this->__r, MYSQL_NUM);
		{
			$»tmp = !$this->cRow === false;
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function next() {
		$GLOBALS['%s']->push("php.db._Mysql.MysqlResultSet::next");
		$»spos = $GLOBALS['%s']->length;
		if(_hx_field($this, "cache") !== null) {
			$t = $this->cache;
			$this->cache = null;
			{
				$GLOBALS['%s']->pop();
				return $t;
			}
		}
		if(!$this->fetchRow()) {
			$GLOBALS['%s']->pop();
			return null;
		}
		$o = _hx_anonymous(array());
		$descriptions = $this->getFieldsDescription();
		{
			$_g1 = 0; $_g = $this->getNFields();
			while($_g1 < $_g) {
				$i = $_g1++;
				$o->{_hx_array_get($descriptions, $i)->name} = $this->convert($this->cRow[$i], _hx_array_get($descriptions, $i)->type);
				unset($i);
			}
		}
		{
			$GLOBALS['%s']->pop();
			return $o;
		}
		$GLOBALS['%s']->pop();
	}
	public function results() {
		$GLOBALS['%s']->push("php.db._Mysql.MysqlResultSet::results");
		$»spos = $GLOBALS['%s']->length;
		$l = new HList();
		while($this->hasNext()) {
			$l->add($this->next());
		}
		{
			$GLOBALS['%s']->pop();
			return $l;
		}
		$GLOBALS['%s']->pop();
	}
	public function getResult($n) {
		$GLOBALS['%s']->push("php.db._Mysql.MysqlResultSet::getResult");
		$»spos = $GLOBALS['%s']->length;
		if($this->cRow === null) {
			if(!$this->fetchRow()) {
				$GLOBALS['%s']->pop();
				return null;
			}
		}
		{
			$»tmp = $this->cRow[$n];
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function getIntResult($n) {
		$GLOBALS['%s']->push("php.db._Mysql.MysqlResultSet::getIntResult");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = intval($this->getResult($n));
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function getFloatResult($n) {
		$GLOBALS['%s']->push("php.db._Mysql.MysqlResultSet::getFloatResult");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = floatval($this->getResult($n));
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
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
	function __toString() { return 'php.db._Mysql.MysqlResultSet'; }
}
