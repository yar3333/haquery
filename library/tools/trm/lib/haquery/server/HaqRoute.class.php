<?php

class haquery_server_HaqRoute {
	public function __construct($url) {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("haquery.server.HaqRoute::new");
		$»spos = $GLOBALS['%s']->length;
		if($url === "index.php" || $url === "index") {
			php_Web::redirect("/");
			php_Sys::hexit(0);
		}
		if(StringTools::endsWith($url, "/index")) {
			php_Web::redirect(_hx_substr($url, 0, strlen($url) - strlen("/index")));
			php_Sys::hexit(0);
		}
		if(file_exists($url) && StringTools::endsWith($url, ".php")) {
			$this->routeType = haquery_server_HaqRouteType::$file;
			$this->path = $url;
		} else {
			$url = trim($url, "/");
			if($url === "") {
				$url = "index";
			}
			$this->path = haquery_base_HaqDefines::$folders->pages . "/" . $url;
			if(haquery_server_HaqRoute::isPageExist($this->path . "/index")) {
				$this->path = $this->path . "/index";
			}
			if(!haquery_server_HaqRoute::isPageExist($this->path)) {
				$p = _hx_explode("/", $this->path);
				$this->pageID = $p->pop();
				$this->path = $p->join("/");
			}
			if(!haquery_server_HaqRoute::isPageExist($this->path)) {
				$this->path .= "/index";
			}
			if(!haquery_server_HaqRoute::isPageExist($this->path)) {
				php_Web::setReturnCode(404);
				php_Lib::hprint("<h1>File not found (404)</h1>");
				php_Sys::hexit(0);
			}
			$this->className = str_replace("/", ".", $this->path) . ".Server";
			if(Type::resolveClass($this->className) === null) {
				$this->className = "haquery.server.HaqPage";
			}
		}
		$GLOBALS['%s']->pop();
	}}
	public $routeType;
	public $path;
	public $className;
	public $pageID;
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
	static function isPageExist($path) {
		$GLOBALS['%s']->push("haquery.server.HaqRoute::isPageExist");
		$»spos = $GLOBALS['%s']->length;
		$path = trim($path, "/") . "/";
		{
			$»tmp = file_exists($path . "template.html") || Type::resolveClass(str_replace("/", ".", $path) . "Server") !== null;
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'haquery.server.HaqRoute'; }
}
