<?php

class haquery_server_Lib {
	public function __construct(){}
	static $config;
	static $profiler;
	static $isPostback;
	static $startTime;
	static function getParamsString() {
		$GLOBALS['%s']->push("haquery.server.Lib::getParamsString");
		$製pos = $GLOBALS['%s']->length;
		$s = php_Web::getParamsString();
		$re = new haquery_EReg("route=[^&]*", "g");
		$s = $re->replace($s, "");
		{
			$裨mp = rtrim($s, "&");
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function run() {
		$GLOBALS['%s']->push("haquery.server.Lib::run");
		$製pos = $GLOBALS['%s']->length;
		try {
			null;
			haquery_server_Lib::$startTime = Date::now()->getTime();
			haxe_Log::$trace = (isset(haquery_server_Lib::$trace) ? haquery_server_Lib::$trace: array("haquery_server_Lib", "trace"));
			haquery_server_Lib::$isPostback = ((php_Web::getParams()->get("HAQUERY_POSTBACK") !== null) ? true : false);
			$route = new haquery_server_HaqRoute(php_Web::getParams()->get("route"));
			haquery_server_Lib::loadBootstraps($route->path);
			if(haquery_server_Lib::$config->autoSessionStart) {
				php_Session::start();
			}
			if(haquery_server_Lib::$config->autoDatabaseConnect && haquery_server_Lib::$config->db->type !== null) {
				haquery_server_db_HaqDb::connect(haquery_server_Lib::$config->db);
			}
			if($route->routeType == haquery_server_HaqRouteType::$file) {
				require($route->path);
			} else {
				$system = new haquery_server_HaqSystem($route, haquery_server_Lib::$isPostback);
			}
			null;
			null;
		}catch(Exception $蜜) {
			$_ex_ = ($蜜 instanceof HException) ? $蜜->e : $蜜;
			$e = $_ex_;
			{
				$GLOBALS['%e'] = new _hx_array(array());
				while($GLOBALS['%s']->length >= $製pos) {
					$GLOBALS['%e']->unshift($GLOBALS['%s']->pop());
				}
				$GLOBALS['%s']->push($GLOBALS['%e'][0]);
				haquery_server_Lib::traceException($e);
			}
		}
		$GLOBALS['%s']->pop();
	}
	static function redirect($url) {
		$GLOBALS['%s']->push("haquery.server.Lib::redirect");
		$製pos = $GLOBALS['%s']->length;
		if(haquery_server_Lib::$isPostback) {
			haquery_server_HaqInternals::addAjaxResponse("haquery.client.Lib.redirect('" . haquery_StringTools::addcslashes($url) . "');");
		} else {
			php_Web::redirect($url);
		}
		$GLOBALS['%s']->pop();
	}
	static function reload() {
		$GLOBALS['%s']->push("haquery.server.Lib::reload");
		$製pos = $GLOBALS['%s']->length;
		if(haquery_server_Lib::$isPostback) {
			haquery_server_HaqInternals::addAjaxResponse("window.location.reload(true);");
		} else {
			haquery_server_Lib::redirect(php_Web::getURI());
		}
		$GLOBALS['%s']->pop();
	}
	static function assert($e, $errorMessage, $pos) {
		$GLOBALS['%s']->push("haquery.server.Lib::assert");
		$製pos = $GLOBALS['%s']->length;
		if(!$e) {
			if($errorMessage === null) {
				$errorMessage = "ASSERT";
			}
			throw new HException($errorMessage . " in " . $pos->fileName . " at line " . $pos->lineNumber);
		}
		$GLOBALS['%s']->pop();
	}
	static function trace($v, $pos) {
		$GLOBALS['%s']->push("haquery.server.Lib::trace");
		$製pos = $GLOBALS['%s']->length;
		if(haquery_server_Lib::$config->filterTracesByIP !== "") {
			if(haquery_server_Lib::$config->filterTracesByIP !== $_SERVER['REMOTE_ADDR']) {
				$GLOBALS['%s']->pop();
				return;
			}
		}
		$text = "";
		if(Type::getClassName(Type::getClass($v)) === "String") {
			$text .= $v;
		} else {
			if($v !== null) {
				$text .= "DUMP\x0A";
				$dump = "";
				ob_start(); var_dump($v); $dump = ob_get_clean();;
				$text .= strip_tags($dump);
			}
		}
		if($text !== "") {
			$isHeadersSent = headers_sent();
			if(!$isHeadersSent) {
				try {
					if(StringTools::startsWith($text, "HAXE EXCEPTION")) {
						FirePHP::getInstance(true)->error($text, null, null);
					} else {
						if(StringTools::startsWith($text, "HAQUERY")) {
							FirePHP::getInstance(true)->info($text, null, null);
						} else {
							$text = $pos->fileName . ":" . $pos->lineNumber . " : " . $text;
							FirePHP::getInstance(true)->warn($text, null, null);
						}
					}
				}catch(Exception $蜜) {
					$_ex_ = ($蜜 instanceof HException) ? $蜜->e : $蜜;
					if(is_string($s = $_ex_)){
						$GLOBALS['%e'] = new _hx_array(array());
						while($GLOBALS['%s']->length >= $製pos) {
							$GLOBALS['%e']->unshift($GLOBALS['%s']->pop());
						}
						$GLOBALS['%s']->push($GLOBALS['%e'][0]);
						$text .= "\x0A\x0AFirePHP exception: " . $s;
					} else throw $蜜;;
				}
			} else {
				php_Lib::println("<script>if (console) console.debug(decodeURIComponent(\"" . rawurlencode("SERVER " . $text) . "\"));</script>");
			}
		}
		if(!file_exists(haquery_base_HaqDefines::$folders->temp)) {
			@mkdir(haquery_base_HaqDefines::$folders->temp, 493);
		}
		$f = php_io_File::append(haquery_base_HaqDefines::$folders->temp . "/haquery.log", false);
		if($f !== null) {
			$f->writeString(haquery_server_Lib_0($f, $pos, $text, $v));
			$f->close();
		}
		$GLOBALS['%s']->pop();
	}
	static function loadBootstraps($relativePath) {
		$GLOBALS['%s']->push("haquery.server.Lib::loadBootstraps");
		$製pos = $GLOBALS['%s']->length;
		$folders = _hx_explode("/", rtrim($relativePath, "/"));
		{
			$_g1 = 1; $_g = $folders->length + 1;
			while($_g1 < $_g) {
				$i = $_g1++;
				$className = $folders->slice(0, $i)->join(".") . ".Bootstrap";
				$clas = Type::resolveClass($className);
				if($clas !== null) {
					$b = Type::createInstance($clas, new _hx_array(array()));
					$b->init(haquery_server_Lib::$config);
					unset($b);
				}
				unset($i,$className,$clas);
			}
		}
		$GLOBALS['%s']->pop();
	}
	static function path2url($path) {
		$GLOBALS['%s']->push("haquery.server.Lib::path2url");
		$製pos = $GLOBALS['%s']->length;
		$realPath = str_replace("\\", "/", haquery_server_Lib_1($path)) . "/" . rtrim($path, "/\\");
		$rootPath = str_replace("\\", "/", $_SERVER['DOCUMENT_ROOT']);
		if(!StringTools::startsWith($realPath, $rootPath)) {
			throw new HException("Can't resolve path '" . $path . "' with realPath = '" . $realPath . "' and rootPath = '" . $rootPath . "'.");
		}
		$n = strlen($rootPath);
		$s = _hx_substr($realPath, $n, null);
		{
			$裨mp = "/" . ltrim($s, "/");
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function traceException($e) {
		$GLOBALS['%s']->push("haquery.server.Lib::traceException");
		$製pos = $GLOBALS['%s']->length;
		$text = "HAXE EXCEPTION: " . Std::string($e) . "\x0A" . "Stack trace:" . str_replace("\x0A", "\x0A\x09", haxe_Stack::toString(haxe_Stack::exceptionStack()));
		$nativeStack = php_Stack::nativeExceptionStack();
		haquery_server_Lib::assert($nativeStack !== null, null, _hx_anonymous(array("fileName" => "Lib.hx", "lineNumber" => 216, "className" => "haquery.server.Lib", "methodName" => "traceException")));
		$text .= "\x0A\x0A";
		$text .= "NATIVE EXCEPTION: " . Std::string($e) . "\x0A";
		$text .= "Stack trace:\x0A";
		{
			$_g = 0;
			while($_g < $nativeStack->length) {
				$row = $nativeStack[$_g];
				++$_g;
				$text .= "\x09";
				if($row->exists("class")) {
					$text .= _hx_add($row->get("class"), $row->get("type"));
				}
				$text .= $row->get("function");
				if($row->exists("file")) {
					$text .= " in " . $row->get("file") . " at line " . $row->get("line") . "\x0A";
				} else {
					$text .= "\x0A";
				}
				unset($row);
			}
		}
		haxe_Log::trace($text, _hx_anonymous(array("fileName" => "Lib.hx", "lineNumber" => 235, "className" => "haquery.server.Lib", "methodName" => "traceException")));
		$GLOBALS['%s']->pop();
	}
	static function hprint($v) {
		$GLOBALS['%s']->push("haquery.server.Lib::print");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = php_Lib::hprint($v);
			$GLOBALS['%s']->pop();
			$裨mp;
			return;
		}
		$GLOBALS['%s']->pop();
	}
	static function println($v) {
		$GLOBALS['%s']->push("haquery.server.Lib::println");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = php_Lib::println($v);
			$GLOBALS['%s']->pop();
			$裨mp;
			return;
		}
		$GLOBALS['%s']->pop();
	}
	static function dump($v) {
		$GLOBALS['%s']->push("haquery.server.Lib::dump");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = php_Lib::dump($v);
			$GLOBALS['%s']->pop();
			$裨mp;
			return;
		}
		$GLOBALS['%s']->pop();
	}
	static function serialize($v) {
		$GLOBALS['%s']->push("haquery.server.Lib::serialize");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = php_Lib::serialize($v);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function unserialize($s) {
		$GLOBALS['%s']->push("haquery.server.Lib::unserialize");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = php_Lib::unserialize($s);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function extensionLoaded($name) {
		$GLOBALS['%s']->push("haquery.server.Lib::extensionLoaded");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = php_Lib::extensionLoaded($name);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function isCli() {
		$GLOBALS['%s']->push("haquery.server.Lib::isCli");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = php_Lib::isCli();
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function printFile($file) {
		$GLOBALS['%s']->push("haquery.server.Lib::printFile");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = php_Lib::printFile($file);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function toPhpArray($a) {
		$GLOBALS['%s']->push("haquery.server.Lib::toPhpArray");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = php_Lib::toPhpArray($a);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function toHaxeArray($a) {
		$GLOBALS['%s']->push("haquery.server.Lib::toHaxeArray");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = new _hx_array($a);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function hashOfAssociativeArray($arr) {
		$GLOBALS['%s']->push("haquery.server.Lib::hashOfAssociativeArray");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = php_Lib::hashOfAssociativeArray($arr);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function associativeArrayOfHash($hash) {
		$GLOBALS['%s']->push("haquery.server.Lib::associativeArrayOfHash");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = php_Lib::associativeArrayOfHash($hash);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function rethrow($e) {
		$GLOBALS['%s']->push("haquery.server.Lib::rethrow");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = php_Lib::rethrow($e);
			$GLOBALS['%s']->pop();
			$裨mp;
			return;
		}
		$GLOBALS['%s']->pop();
	}
	static function getClasses() {
		$GLOBALS['%s']->push("haquery.server.Lib::getClasses");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = php_Lib::getClasses();
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function loadLib($pathToLib) {
		$GLOBALS['%s']->push("haquery.server.Lib::loadLib");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = php_Lib::loadLib($pathToLib);
			$GLOBALS['%s']->pop();
			$裨mp;
			return;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'haquery.server.Lib'; }
}
haquery_server_Lib::$config = new haquery_server_HaqConfig();
haquery_server_Lib::$profiler = new haquery_server_HaqProfiler();
function haquery_server_Lib_0(&$f, &$pos, &$text, &$v) {
	$製pos = $GLOBALS['%s']->length;
	if($text !== "") {
		return sprintf("%.3f", (Date::now()->getTime() - haquery_server_Lib::$startTime) / 1000.0) . " " . str_replace("\x0A", "\x0A\x09", $text) . "\x0A";
	} else {
		return "\x0A";
	}
}
function haquery_server_Lib_1(&$path) {
	$製pos = $GLOBALS['%s']->length;
	{
		$p = realpath("");
		if(($p === false)) {
			return null;
		} else {
			return $p;
		}
		unset($p);
	}
}
