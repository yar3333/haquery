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
		$製pos = $GLOBALS['%s']->length;
		haquery_base_HaQuery::$startTime = Date::now()->getTime();
		haxe_Log::$trace = (isset(haquery_base_HaQuery::$trace) ? haquery_base_HaQuery::$trace: array("haquery_base_HaQuery", "trace"));
		$route = new haquery_server_HaqRoute(php_Web::getParams()->get("route"));
		haquery_base_HaQuery::loadBootstraps($route->pagePath);
		if(haquery_base_HaQuery::$config->autoSessionStart) {
			php_Session::start();
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
	static function error($message, $pos) {
		$GLOBALS['%s']->push("haquery.base.HaQuery::error");
		$製pos = $GLOBALS['%s']->length;
		$stack = new _hx_array(debug_backtrace());
		$frow = php_Lib::hashOfAssociativeArray($stack->shift());
		$text = "\x0A" . "\x09 in class <b>" . $pos->className . "</b> in file <b>" . $pos->fileName . "</b> at line <b>" . $pos->lineNumber . "</b>\x0A" . "\x09 in <b>" . $frow->get("file") . "</b> at line <b>" . $frow->get("line") . "</b>\x0A" . "Stack trace:\x0A";
		{
			$_g = 0;
			while($_g < $stack->length) {
				$nrow = $stack[$_g];
				++$_g;
				$row = php_Lib::hashOfAssociativeArray($nrow);
				$text .= "\x09<b>";
				if($row->exists("class")) {
					$text .= _hx_add(_hx_add($row->get("class"), $row->get("type")), $row->get("function"));
				} else {
					$text .= $row->get("function");
				}
				if($row->exists("file")) {
					$text .= "</b> in <b>" . $row->get("file") . "</b> at line <b>" . $row->get("line") . "</b>\x0A";
					$args = "";
					if($row->exists("args")) {
						$argsArray = new _hx_array($row->get("args"));
						unset($argsArray);
					}
					$text .= haquery_base_HaQuery_0($_g, $args, $frow, $message, $nrow, $pos, $row, $stack, $text);
					unset($args);
				} else {
					$text .= "\x0A";
				}
				unset($row,$nrow);
			}
		}
		haquery_base_HaQuery::trace("ERROR: " . $message . strip_tags($text), _hx_anonymous(array("fileName" => "HaQuery.hx", "lineNumber" => 151, "className" => "haquery.base.HaQuery", "methodName" => "error")));
		php_Lib::hprint(str_replace("\x09", "&nbsp;&nbsp;&nbsp;&nbsp;", str_replace("\x0A", "<br />", "HAQUERY <b>ERROR:</b> " . StringTools::htmlEscape($message) . $text)));
		php_Sys::hexit(1);
		$GLOBALS['%s']->pop();
	}
	static function assert($e, $errorMessage, $pos) {
		$GLOBALS['%s']->push("haquery.base.HaQuery::assert");
		$製pos = $GLOBALS['%s']->length;
		if(!$e) {
			haquery_base_HaQuery::error(haquery_base_HaQuery_1($e, $errorMessage, $pos), $pos);
		}
		$GLOBALS['%s']->pop();
	}
	static function loadBootstraps($relativePath) {
		$GLOBALS['%s']->push("haquery.base.HaQuery::loadBootstraps");
		$製pos = $GLOBALS['%s']->length;
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
		$製pos = $GLOBALS['%s']->length;
		$path = str_replace("\\", "/", realpath($path));
		$rootPath = str_replace("\\", "/", $_SERVER['DOCUMENT_ROOT']);
		if(!StringTools::startsWith($path, $rootPath)) {
			haquery_base_HaQuery::error("Can't resolve path '" . $path . "'.", _hx_anonymous(array("fileName" => "HaQuery.hx", "lineNumber" => 206, "className" => "haquery.base.HaQuery", "methodName" => "path2url")));
		}
		$n = strlen($rootPath);
		$s = _hx_substr($path, $n, null);
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
			$裨mp = $e === null;
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function trace($v, $pos) {
		$GLOBALS['%s']->push("haquery.base.HaQuery::trace");
		$製pos = $GLOBALS['%s']->length;
		if(haquery_base_HaQuery::$config->traceFilter_IP !== "") {
			if(haquery_base_HaQuery::$config->traceFilter_IP !== $_SERVER['REMOTE_ADDR']) {
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
				$text .= htmlspecialchars_decode(strip_tags($dump));
			}
		}
		$tempDir = _hx_deref(_hx_anonymous(array("pages" => "pages/", "support" => "support/", "temp" => "temp/")))->temp;
		if(!file_exists($tempDir)) {
			@mkdir($tempDir, 493);
		}
		$f = php_io_File::append($tempDir . "haquery.log", false);
		if($f !== null) {
			$f->writeString(haquery_base_HaQuery_2($f, $pos, $tempDir, $text, $v));
			$f->close();
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'haquery.base.HaQuery'; }
}
haquery_base_HaQuery::$folders = _hx_anonymous(array("pages" => "pages/", "support" => "support/", "temp" => "temp/"));
haquery_base_HaQuery::$config = new haquery_server_HaqConfig();
function haquery_base_HaQuery_0(&$_g, &$args, &$frow, &$message, &$nrow, &$pos, &$row, &$stack, &$text) {
	if($args !== "") {
		return "\x09\x09" . $args . "\x0A";
	} else {
		return "";
	}
}
function haquery_base_HaQuery_1(&$e, &$errorMessage, &$pos) {
	if($errorMessage !== null) {
		return $errorMessage;
	} else {
		return "ASSERT";
	}
}
function haquery_base_HaQuery_2(&$f, &$pos, &$tempDir, &$text, &$v) {
	if($text !== null) {
		return sprintf("%.3f", Date::now()->getTime() - haquery_base_HaQuery::$startTime) . " HAQUERY " . str_replace("\x0A", "\x0A\x09", $text) . "\x0A";
	} else {
		return "\x0A";
	}
}
