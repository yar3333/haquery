<?php

class php_Session {
	public function __construct(){}
	static function getCacheLimiter() {
		$GLOBALS['%s']->push("php.Session::getCacheLimiter");
		$製pos = $GLOBALS['%s']->length;
		switch(session_cache_limiter()) {
		case "public":{
			$裨mp = php_CacheLimiter::$Public;
			$GLOBALS['%s']->pop();
			return $裨mp;
		}break;
		case "private":{
			$裨mp = php_CacheLimiter::$Private;
			$GLOBALS['%s']->pop();
			return $裨mp;
		}break;
		case "nocache":{
			$裨mp = php_CacheLimiter::$NoCache;
			$GLOBALS['%s']->pop();
			return $裨mp;
		}break;
		case "private_no_expire":{
			$裨mp = php_CacheLimiter::$PrivateNoExpire;
			$GLOBALS['%s']->pop();
			return $裨mp;
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
		$製pos = $GLOBALS['%s']->length;
		if(php_Session::$started) {
			throw new HException("You can't set the cache limiter while the session is already in use");
		}
		$裨 = ($l);
		switch($裨->index) {
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
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = session_cache_expire();
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function setCacheExpire($minutes) {
		$GLOBALS['%s']->push("php.Session::setCacheExpire");
		$製pos = $GLOBALS['%s']->length;
		if(php_Session::$started) {
			throw new HException("You can't set the cache expire time while the session is already in use");
		}
		session_cache_expire($minutes);
		$GLOBALS['%s']->pop();
	}
	static function setName($name) {
		$GLOBALS['%s']->push("php.Session::setName");
		$製pos = $GLOBALS['%s']->length;
		if(php_Session::$started) {
			throw new HException("You can't set the name while the session is already in use");
		}
		session_name($name);
		$GLOBALS['%s']->pop();
	}
	static function getName() {
		$GLOBALS['%s']->push("php.Session::getName");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = session_name();
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getId() {
		$GLOBALS['%s']->push("php.Session::getId");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = session_id();
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function setId($id) {
		$GLOBALS['%s']->push("php.Session::setId");
		$製pos = $GLOBALS['%s']->length;
		if(php_Session::$started) {
			throw new HException("You can't set the session id while the session is already in use");
		}
		session_id($id);
		$GLOBALS['%s']->pop();
	}
	static function getSavePath() {
		$GLOBALS['%s']->push("php.Session::getSavePath");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = session_save_path();
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function setSavePath($path) {
		$GLOBALS['%s']->push("php.Session::setSavePath");
		$製pos = $GLOBALS['%s']->length;
		if(php_Session::$started) {
			throw new HException("You can't set the save path while the session is already in use");
		}
		session_save_path($path);
		$GLOBALS['%s']->pop();
	}
	static function getModule() {
		$GLOBALS['%s']->push("php.Session::getModule");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = session_module_name();
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function setModule($module) {
		$GLOBALS['%s']->push("php.Session::setModule");
		$製pos = $GLOBALS['%s']->length;
		if(php_Session::$started) {
			throw new HException("You can't set the module while the session is already in use");
		}
		session_module_name($module);
		$GLOBALS['%s']->pop();
	}
	static function regenerateId($deleteold) {
		$GLOBALS['%s']->push("php.Session::regenerateId");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = session_regenerate_id($deleteold);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function get($name) {
		$GLOBALS['%s']->push("php.Session::get");
		$製pos = $GLOBALS['%s']->length;
		php_Session::start();
		if(!isset($_SESSION[$name])) {
			$GLOBALS['%s']->pop();
			return null;
		}
		{
			$裨mp = $_SESSION[$name];
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function set($name, $value) {
		$GLOBALS['%s']->push("php.Session::set");
		$製pos = $GLOBALS['%s']->length;
		php_Session::start();
		{
			$裨mp = $_SESSION[$name] = $value;
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function setCookieParams($lifetime, $path, $domain, $secure, $httponly) {
		$GLOBALS['%s']->push("php.Session::setCookieParams");
		$製pos = $GLOBALS['%s']->length;
		if(php_Session::$started) {
			throw new HException("You can't set the cookie params while the session is already in use");
		}
		session_set_cookie_params($lifetime, $path, $domain, $secure, $httponly);
		$GLOBALS['%s']->pop();
	}
	static function getCookieParams() {
		$GLOBALS['%s']->push("php.Session::getCookieParams");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = _hx_anonymous(session_get_cookie_params());
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function setSaveHandler($open, $close, $read, $write, $destroy, $gc) {
		$GLOBALS['%s']->push("php.Session::setSaveHandler");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = session_set_save_handler($open, $close, $read, $write, $destroy, $gc);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function exists($name) {
		$GLOBALS['%s']->push("php.Session::exists");
		$製pos = $GLOBALS['%s']->length;
		php_Session::start();
		{
			$裨mp = array_key_exists($name, $_SESSION);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function remove($name) {
		$GLOBALS['%s']->push("php.Session::remove");
		$製pos = $GLOBALS['%s']->length;
		php_Session::start();
		unset($_SESSION[$name]);
		$GLOBALS['%s']->pop();
	}
	static $started;
	static function start() {
		$GLOBALS['%s']->push("php.Session::start");
		$製pos = $GLOBALS['%s']->length;
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
		$製pos = $GLOBALS['%s']->length;
		session_unset();
		$GLOBALS['%s']->pop();
	}
	static function close() {
		$GLOBALS['%s']->push("php.Session::close");
		$製pos = $GLOBALS['%s']->length;
		session_write_close();
		php_Session::$started = false;
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'php.Session'; }
}
php_Session::$started = isset($_SESSION);
