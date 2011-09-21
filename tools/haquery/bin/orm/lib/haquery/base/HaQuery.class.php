<?php

class haquery_base_HaQuery {
	public function __construct(){}
	static $VERSION = 2.0;
	static $folders;
	static $config;
	static $isPostback = false;
	static $startTime;
	static function run() {
		$GLOBALS['%s']->push("haquery.base.HaQuery::run");
		$製pos = $GLOBALS['%s']->length;
		haquery_base_HaQuery::$startTime = Date::now()->getTime();
		haxe_Log::$trace = (isset(haquery_base_HaQuery::$trace) ? haquery_base_HaQuery::$trace: array("haquery_base_HaQuery", "trace"));
		$route = new haquery_server_HaqRoute(php_Web::getParams()->get("route"));
		haquery_base_HaQuery::loadBootstraps($route->path);
		if(haquery_base_HaQuery::$config->autoSessionStart) {
			php_Session::start();
		}
		if(haquery_base_HaQuery::$config->autoDatabaseConnect && haquery_base_HaQuery::$config->db->type !== null) {
			haquery_server_db_HaqDb::connect(haquery_base_HaQuery::$config->db);
		}
		if($route->routeType == haquery_server_HaqRouteType::$file) {
			require($route->path);
		} else {
			$system = new haquery_server_HaqSystem($route);
		}
		$GLOBALS['%s']->pop();
	}
	static function redirect($url) {
		$GLOBALS['%s']->push("haquery.base.HaQuery::redirect");
		$製pos = $GLOBALS['%s']->length;
		if(haquery_base_HaQuery::$isPostback) {
			haquery_server_HaqInternals::addAjaxAnswer("window.location.href = '" . haquery_base_HaQuery::jsEscape($url) . "';");
		} else {
			php_Web::redirect($url);
		}
		$GLOBALS['%s']->pop();
	}
	static function reload() {
		$GLOBALS['%s']->push("haquery.base.HaQuery::reload");
		$製pos = $GLOBALS['%s']->length;
		if(haquery_base_HaQuery::$isPostback) {
			haquery_server_HaqInternals::addAjaxAnswer("window.location.reload(true);");
		} else {
			haquery_base_HaQuery::redirect(php_Web::getURI());
		}
		$GLOBALS['%s']->pop();
	}
	static function assert($e, $errorMessage, $pos) {
		$GLOBALS['%s']->push("haquery.base.HaQuery::assert");
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
		$GLOBALS['%s']->push("haquery.base.HaQuery::trace");
		$製pos = $GLOBALS['%s']->length;
		if(haquery_base_HaQuery::$config->filterTracesByIP !== "") {
			if(haquery_base_HaQuery::$config->filterTracesByIP !== $_SERVER['REMOTE_ADDR']) {
				$GLOBALS['%s']->pop();
				return;
			}
		}
		$text = "";
		if(Type::getClassName(Type::getClass($v)) === "String") {
			$text .= $v;
		} else {
			if(!haquery_base_HaQuery::isNull($v)) {
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
		if(!file_exists(haquery_base_HaQuery::$folders->temp)) {
			@mkdir(haquery_base_HaQuery::$folders->temp, 493);
		}
		$f = php_io_File::append(haquery_base_HaQuery::$folders->temp . "/haquery.log", false);
		if($f !== null) {
			$f->writeString(haquery_base_HaQuery_0($f, $pos, $text, $v));
			$f->close();
		}
		$GLOBALS['%s']->pop();
	}
	static function loadBootstraps($relativePath) {
		$GLOBALS['%s']->push("haquery.base.HaQuery::loadBootstraps");
		$製pos = $GLOBALS['%s']->length;
		$folders = _hx_explode("/", rtrim($relativePath, "/"));
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
		$製pos = $GLOBALS['%s']->length;
		$realPath = str_replace("\\", "/", php_FileSystem::fullPath("")) . "/" . rtrim($path, "/\\");
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
	static function jsEscape($s) {
		$GLOBALS['%s']->push("haquery.base.HaQuery::jsEscape");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = addcslashes($s, "'\"\x09\x0D\x0A\\");
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function isNull($e) {
		$GLOBALS['%s']->push("haquery.base.HaQuery::isNull");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = ($e === null);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function traceException($e) {
		$GLOBALS['%s']->push("haquery.base.HaQuery::traceException");
		$製pos = $GLOBALS['%s']->length;
		$text = "HAXE EXCEPTION: " . Std::string($e) . "\x0A" . "Stack trace:" . str_replace("\x0A", "\x0A\x09", haxe_Stack::toString(haxe_Stack::exceptionStack()));
		$nativeStack = php_Stack::nativeExceptionStack();
		haquery_base_HaQuery::assert($nativeStack !== null, null, _hx_anonymous(array("fileName" => "HaQuery.hx", "lineNumber" => 247, "className" => "haquery.base.HaQuery", "methodName" => "traceException")));
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
		haxe_Log::trace($text, _hx_anonymous(array("fileName" => "HaQuery.hx", "lineNumber" => 264, "className" => "haquery.base.HaQuery", "methodName" => "traceException")));
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'haquery.base.HaQuery'; }
}
haquery_base_HaQuery::$folders = _hx_anonymous(array("pages" => "pages", "support" => "support", "temp" => "temp"));
haquery_base_HaQuery::$config = new haquery_server_HaqConfig();
function haquery_base_HaQuery_0(&$f, &$pos, &$text, &$v) {
	$製pos = $GLOBALS['%s']->length;
	if($text !== "") {
		return sprintf("%.3f", (Date::now()->getTime() - haquery_base_HaQuery::$startTime) / 1000.0) . " " . str_replace("\x0A", "\x0A\x09", $text) . "\x0A";
	} else {
		return "\x0A";
	}
}
