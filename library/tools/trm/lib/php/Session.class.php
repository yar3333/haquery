<?php

class php_Session {
	public function __construct(){}
	static function getCacheLimiter() {
		$GLOBALS['%s']->push("php.Session::getCacheLimiter");
		$�spos = $GLOBALS['%s']->length;
		switch(session_cache_limiter()) {
		case "public":{
			$�tmp = php_CacheLimiter::$Public;
			$GLOBALS['%s']->pop();
			return $�tmp;
		}break;
		case "private":{
			$�tmp = php_CacheLimiter::$Private;
			$GLOBALS['%s']->pop();
			return $�tmp;
		}break;
		case "nocache":{
			$�tmp = php_CacheLimiter::$NoCache;
			$GLOBALS['%s']->pop();
			return $�tmp;
		}break;
		case "private_no_expire":{
			$�tmp = php_CacheLimiter::$PrivateNoExpire;
			$GLOBALS['%s']->pop();
			return $�tmp;
		}break;
		}
		{
			$GLOBALS['%s']->pop();
			return null;
		}
		$GLOBALS['%s']->pop();
	}
	static function setCacheLimiter($l) {
		$GLOBALS['%s']->push("php.Session::setCacheLimiter");
		$�spos = $GLOBALS['%s']->length;
		if(php_Session::$started) {
			throw new HException("You can't set the cache limiter while the session is already in use");
		}
		$�t = ($l);
		switch($�t->index) {
		case 0:
		{
			session_cache_limiter("public");
		}break;
		case 1:
		{
			session_cache_limiter("private");
		}break;
		case 2:
		{
			session_cache_limiter("nocache");
		}break;
		case 3:
		{
			session_cache_limiter("private_no_expire");
		}break;
		}
		$GLOBALS['%s']->pop();
	}
	static function getCacheExpire() {
		$GLOBALS['%s']->push("php.Session::getCacheExpire");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = session_cache_expire();
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function setCacheExpire($minutes) {
		$GLOBALS['%s']->push("php.Session::setCacheExpire");
		$�spos = $GLOBALS['%s']->length;
		if(php_Session::$started) {
			throw new HException("You can't set the cache expire time while the session is already in use");
		}
		session_cache_expire($minutes);
		$GLOBALS['%s']->pop();
	}
	static function setName($name) {
		$GLOBALS['%s']->push("php.Session::setName");
		$�spos = $GLOBALS['%s']->length;
		if(php_Session::$started) {
			throw new HException("You can't set the name while the session is already in use");
		}
		session_name($name);
		$GLOBALS['%s']->pop();
	}
	static function getName() {
		$GLOBALS['%s']->push("php.Session::getName");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = session_name();
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getId() {
		$GLOBALS['%s']->push("php.Session::getId");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = session_id();
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function setId($id) {
		$GLOBALS['%s']->push("php.Session::setId");
		$�spos = $GLOBALS['%s']->length;
		if(php_Session::$started) {
			throw new HException("You can't set the session id while the session is already in use");
		}
		session_id($id);
		$GLOBALS['%s']->pop();
	}
	static function getSavePath() {
		$GLOBALS['%s']->push("php.Session::getSavePath");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = session_save_path();
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function setSavePath($path) {
		$GLOBALS['%s']->push("php.Session::setSavePath");
		$�spos = $GLOBALS['%s']->length;
		if(php_Session::$started) {
			throw new HException("You can't set the save path while the session is already in use");
		}
		session_save_path($path);
		$GLOBALS['%s']->pop();
	}
	static function getModule() {
		$GLOBALS['%s']->push("php.Session::getModule");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = session_module_name();
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function setModule($module) {
		$GLOBALS['%s']->push("php.Session::setModule");
		$�spos = $GLOBALS['%s']->length;
		if(php_Session::$started) {
			throw new HException("You can't set the module while the session is already in use");
		}
		session_module_name($module);
		$GLOBALS['%s']->pop();
	}
	static function regenerateId($deleteold) {
		$GLOBALS['%s']->push("php.Session::regenerateId");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = session_regenerate_id($deleteold);
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function get($name) {
		$GLOBALS['%s']->push("php.Session::get");
		$�spos = $GLOBALS['%s']->length;
		php_Session::start();
		if(!isset($_SESSION[$name])) {
			$GLOBALS['%s']->pop();
			return null;
		}
		{
			$�tmp = $_SESSION[$name];
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function set($name, $value) {
		$GLOBALS['%s']->push("php.Session::set");
		$�spos = $GLOBALS['%s']->length;
		php_Session::start();
		{
			$�tmp = $_SESSION[$name] = $value;
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function setCookieParams($lifetime, $path, $domain, $secure, $httponly) {
		$GLOBALS['%s']->push("php.Session::setCookieParams");
		$�spos = $GLOBALS['%s']->length;
		if(php_Session::$started) {
			throw new HException("You can't set the cookie params while the session is already in use");
		}
		session_set_cookie_params($lifetime, $path, $domain, $secure, $httponly);
		$GLOBALS['%s']->pop();
	}
	static function getCookieParams() {
		$GLOBALS['%s']->push("php.Session::getCookieParams");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = _hx_anonymous(session_get_cookie_params());
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function setSaveHandler($open, $close, $read, $write, $destroy, $gc) {
		$GLOBALS['%s']->push("php.Session::setSaveHandler");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = session_set_save_handler($open, $close, $read, $write, $destroy, $gc);
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function exists($name) {
		$GLOBALS['%s']->push("php.Session::exists");
		$�spos = $GLOBALS['%s']->length;
		php_Session::start();
		{
			$�tmp = array_key_exists($name, $_SESSION);
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function remove($name) {
		$GLOBALS['%s']->push("php.Session::remove");
		$�spos = $GLOBALS['%s']->length;
		php_Session::start();
		unset($_SESSION[$name]);
		$GLOBALS['%s']->pop();
	}
	static $started;
	static function start() {
		$GLOBALS['%s']->push("php.Session::start");
		$�spos = $GLOBALS['%s']->length;
		if(php_Session::$started) {
			$GLOBALS['%s']->pop();
			return;
		}
		php_Session::$started = true;
		session_start();
		$GLOBALS['%s']->pop();
	}
	static function clear() {
		$GLOBALS['%s']->push("php.Session::clear");
		$�spos = $GLOBALS['%s']->length;
		session_unset();
		$GLOBALS['%s']->pop();
	}
	static function close() {
		$GLOBALS['%s']->push("php.Session::close");
		$�spos = $GLOBALS['%s']->length;
		session_write_close();
		php_Session::$started = false;
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'php.Session'; }
}
php_Session::$started = isset($_SESSION);
