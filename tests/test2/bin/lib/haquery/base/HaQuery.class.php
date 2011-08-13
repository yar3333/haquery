<?php

class haquery_base_HaQuery {
	public function __construct(){}
	static $VERSION = 2.1;
	static $folders;
	static $config;
	static $isPostback = false;
	static $startTime;
	static function run() {
		$GLOBALS['%s']->push("haquery.base.HaQuery::run");
		$�spos = $GLOBALS['%s']->length;
		haquery_base_HaQuery::$startTime = Date::now()->getTime();
		haxe_Log::$trace = (isset(haquery_base_HaQuery::$trace) ? haquery_base_HaQuery::$trace: array("haquery_base_HaQuery", "trace"));
		$route = new haquery_server_HaqRoute(php_Web::getParams()->get("route"));
		haquery_base_HaQuery::loadBootstraps($route->pagePath);
		if(haquery_base_HaQuery::$config->autoSessionStart) {
			php_Session::start();
		}
		if(haquery_base_HaQuery::$config->autoDatabaseConnect && haquery_base_HaQuery::$config->db->type !== null) {
			haquery_server_db_HaqDb::connect(haquery_base_HaQuery::$config->db);
		}
		if($route->routeType == haquery_server_HaqRouteType::$file) {
			php_FileSystem::setCurrentDirectory(dirname($route->pagePath));
			require(basename($route->pagePath));
		} else {
			$system = new haquery_server_HaqSystem($route);
		}
		$GLOBALS['%s']->pop();
	}
	static function redirect($url) {
		$GLOBALS['%s']->push("haquery.base.HaQuery::redirect");
		$�spos = $GLOBALS['%s']->length;
		if(haquery_base_HaQuery::$isPostback) {
			haquery_server_HaqInternals::addAjaxAnswer("window.location.href = '" . haquery_base_HaQuery::jsEscape($url) . "';");
		} else {
			php_Web::redirect($url);
		}
		$GLOBALS['%s']->pop();
	}
	static function reload() {
		$GLOBALS['%s']->push("haquery.base.HaQuery::reload");
		$�spos = $GLOBALS['%s']->length;
		if(haquery_base_HaQuery::$isPostback) {
			haquery_server_HaqInternals::addAjaxAnswer("window.location.reload(true);");
		} else {
			haquery_base_HaQuery::redirect(php_Web::getURI());
		}
		$GLOBALS['%s']->pop();
	}
	static function assert($e, $errorMessage, $pos) {
		$GLOBALS['%s']->push("haquery.base.HaQuery::assert");
		$�spos = $GLOBALS['%s']->length;
		if(!$e) {
			if($errorMessage === null) {
				$errorMessage = "ASSERT";
			}
			throw new HException($errorMessage . " in " . $pos->fileName . " at line " . $pos->lineNumber);
		}
		$GLOBALS['%s']->pop();
	}
	static function loadBootstraps($relativePath) {
		$GLOBALS['%s']->push("haquery.base.HaQuery::loadBootstraps");
		$�spos = $GLOBALS['%s']->length;
		$folders = _hx_explode("/", trim($relativePath, "/"));
		{
			$_g1 = 0; $_g = $folders->length;
			while($_g1 < $_g) {
				$i = $_g1++;
				$className = $folders->slice(0, $i)->join(".") . ".Bootstrap";
				$clas = Type::resolveClass($className);
				if($clas !== null) {
					$b = Type::createInstance($clas, new _hx_array(array()));
					$b->init(haquery_base_HaQuery::$config);
					unset($b);
				}
				unset($i,$className,$clas);
			}
		}
		$GLOBALS['%s']->pop();
	}
	static function path2url($path) {
		$GLOBALS['%s']->push("haquery.base.HaQuery::path2url");
		$�spos = $GLOBALS['%s']->length;
		$realPath = str_replace("\\", "/", realpath("")) . "/" . trim($path, "/\\");
		$rootPath = str_replace("\\", "/", $_SERVER['DOCUMENT_ROOT']);
		if(!StringTools::startsWith($realPath, $rootPath)) {
			throw new HException("Can't resolve path '" . $path . "' with realPath = '" . $realPath . "' and rootPath = '" . $rootPath . "'.");
		}
		$n = strlen($rootPath);
		$s = _hx_substr($realPath, $n, null);
		{
			$�tmp = "/" . ltrim($s, "/");
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function jsEscape($s) {
		$GLOBALS['%s']->push("haquery.base.HaQuery::jsEscape");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = addcslashes($s, "'\"\x09\x0D\x0A\\");
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function isNull($e) {
		$GLOBALS['%s']->push("haquery.base.HaQuery::isNull");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = $e === null;
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function trace($v, $pos) {
		$GLOBALS['%s']->push("haquery.base.HaQuery::trace");
		$�spos = $GLOBALS['%s']->length;
		if(haquery_base_HaQuery::$config->filterTracesByIP !== "") {
			if(haquery_base_HaQuery::$config->filterTracesByIP !== $_SERVER['REMOTE_ADDR']) {
				$GLOBALS['%s']->pop();
				return;
			}
		}
		$text = "";
		if(Type::getClassName(Type::getClass($v)) === "String") {
			$text = $v;
		} else {
			if(!haquery_base_HaQuery::isNull($v)) {
				$text = "DUMP " . $pos->fileName . ":" . $pos->lineNumber . "\x0A";
				$dump = "";
				ob_start(); var_dump($v); $dump = ob_get_clean();;
				$text .= $dump;
			}
		}
		$tempDir = _hx_deref(_hx_anonymous(array("pages" => "pages/", "support" => "support/", "temp" => "temp/")))->temp;
		if(!file_exists($tempDir)) {
			@mkdir($tempDir, 493);
		}
		if($text !== "") {
			php_Lib::println("<script>if (console) console.debug(decodeURIComponent(\"" . rawurlencode($text) . "\"));</script>");
		}
		$f = php_io_File::append($tempDir . "haquery.log", false);
		if($f !== null) {
			$f->writeString(haquery_base_HaQuery_0($f, $pos, $tempDir, $text, $v));
			$f->close();
		}
		$GLOBALS['%s']->pop();
	}
	static function traceException($e) {
		$GLOBALS['%s']->push("haquery.base.HaQuery::traceException");
		$�spos = $GLOBALS['%s']->length;
		$text = "HAXE EXCEPTION: " . Std::string($e) . "\x0A" . "Stack trace:" . str_replace("\x0A", "\x0A\x09", haxe_Stack::toString(haxe_Stack::exceptionStack()));
		$nativeStack = haxe_Stack::nativeExceptionStack();
		haquery_base_HaQuery::assert($nativeStack !== null, null, _hx_anonymous(array("fileName" => "HaQuery.hx", "lineNumber" => 259, "className" => "haquery.base.HaQuery", "methodName" => "traceException")));
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
		haxe_Log::trace($text, _hx_anonymous(array("fileName" => "HaQuery.hx", "lineNumber" => 276, "className" => "haquery.base.HaQuery", "methodName" => "traceException")));
		php_Sys::hexit(1);
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'haquery.base.HaQuery'; }
}
haquery_base_HaQuery::$folders = _hx_anonymous(array("pages" => "pages/", "support" => "support/", "temp" => "temp/"));
haquery_base_HaQuery::$config = new haquery_server_HaqConfig();
function haquery_base_HaQuery_0(&$f, &$pos, &$tempDir, &$text, &$v) {
	if($text !== null) {
		return sprintf("%.3f", Date::now()->getTime() - haquery_base_HaQuery::$startTime) . " HAQUERY " . str_replace("\x0A", "\x0A\x09", $text) . "\x0A";
	} else {
		return "\x0A";
	}
}
