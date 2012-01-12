<?php

class haquery_server_Lib {
	public function __construct(){}
	static $config;
	static $profiler;
	static $isPostback;
	static $startTime;
	static function getParamsString() {
		$s = php_Web::getParamsString();
		$re = new haquery_EReg("route=[^&]*", "g");
		$s = $re->replace($s, "");
		return trim($s, "&");
	}
	static function run() {
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
		}catch(Exception $»e) {
			$_ex_ = ($»e instanceof HException) ? $»e->e : $»e;
			$e = $_ex_;
			{
				haquery_server_Lib::traceException($e);
			}
		}
	}
	static function redirect($url) {
		if(haquery_server_Lib::$isPostback) {
			haquery_server_HaqInternals::addAjaxResponse("haquery.client.Lib.redirect('" . haquery_StringTools::addcslashes($url) . "');");
		} else {
			php_Web::redirect($url);
		}
	}
	static function reload() {
		if(haquery_server_Lib::$isPostback) {
			haquery_server_HaqInternals::addAjaxResponse("window.location.reload(true);");
		} else {
			haquery_server_Lib::redirect(php_Web::getURI());
		}
	}
	static function assert($e, $errorMessage, $pos) {
	}
	static function trace($v, $pos) {
		if(haquery_server_Lib::$config->filterTracesByIP !== "") {
			if(haquery_server_Lib::$config->filterTracesByIP !== $_SERVER['REMOTE_ADDR']) {
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
				}catch(Exception $»e) {
					$_ex_ = ($»e instanceof HException) ? $»e->e : $»e;
					if(is_string($s = $_ex_)){
						$text .= "\x0A\x0AFirePHP exception: " . $s;
					} else throw $»e;;
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
	}
	static function loadBootstraps($relativePath) {
		$folders = _hx_explode("/", trim($relativePath, "/"));
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
	}
	static function path2url($path) {
		$realPath = str_replace("\\", "/", haquery_server_Lib_1($path)) . "/" . trim($path, "/\\");
		$rootPath = str_replace("\\", "/", haquery_server_Web::getDocumentRoot());
		if(!StringTools::startsWith($realPath, $rootPath)) {
			throw new HException("Can't resolve path '" . $path . "' with realPath = '" . $realPath . "' and rootPath = '" . $rootPath . "'.");
		}
		$n = strlen($rootPath);
		$s = _hx_substr($realPath, $n, null);
		return "/" . ltrim($s, "/");
	}
	static function traceException($e) {
		$text = "HAXE EXCEPTION: " . Std::string($e) . "\x0A" . "Stack trace:" . str_replace("\x0A", "\x0A\x09", haxe_Stack::toString(haxe_Stack::exceptionStack()));
		$nativeStack = php_Stack::nativeExceptionStack();
		null;
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
	}
	static function mail($email, $fromEmail, $subject, $message) {
		$headers = "MIME-Version: 1.0\x0D\x0A";
		$headers .= "Content-Type: text/plain; charset=utf-8\x0D\x0A";
		$headers .= "Date: " . Date::now() . "\x0D\x0A";
		$headers .= "From: " . $fromEmail . "\x0D\x0A";
		$headers .= "X-Mailer: My Send E-mail\x0D\x0A";
		return mail($email, $subject, $message, $headers);
	}
	static function hprint($v) {
		php_Lib::hprint($v);
		return;
	}
	static function println($v) {
		php_Lib::println($v);
		return;
	}
	static function dump($v) {
		php_Lib::dump($v);
		return;
	}
	static function serialize($v) {
		return php_Lib::serialize($v);
	}
	static function unserialize($s) {
		return php_Lib::unserialize($s);
	}
	static function extensionLoaded($name) {
		return php_Lib::extensionLoaded($name);
	}
	static function isCli() {
		return php_Lib::isCli();
	}
	static function printFile($file) {
		return php_Lib::printFile($file);
	}
	static function toPhpArray($a) {
		return php_Lib::toPhpArray($a);
	}
	static function toHaxeArray($a) {
		return new _hx_array($a);
	}
	static function hashOfAssociativeArray($arr) {
		return php_Lib::hashOfAssociativeArray($arr);
	}
	static function associativeArrayOfHash($hash) {
		return php_Lib::associativeArrayOfHash($hash);
	}
	static function rethrow($e) {
		php_Lib::rethrow($e);
		return;
	}
	static function getClasses() {
		return php_Lib::getClasses();
	}
	static function loadLib($pathToLib) {
		php_Lib::loadLib($pathToLib);
		return;
	}
	function __toString() { return 'haquery.server.Lib'; }
}
haquery_server_Lib::$config = new haquery_server_HaqConfig();
haquery_server_Lib::$profiler = new haquery_server_HaqProfiler();
function haquery_server_Lib_0(&$f, &$pos, &$text, &$v) {
	if($text !== "") {
		return sprintf("%.3f", (Date::now()->getTime() - haquery_server_Lib::$startTime) / 1000.0) . " " . str_replace("\x0A", "\x0D\x0A\x09", $text) . "\x0D\x0A";
	} else {
		return "\x0D\x0A";
	}
}
function haquery_server_Lib_1(&$path) {
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
