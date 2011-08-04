<?php

class haquery_server_HaqRoute {
	public function __construct($path) {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("haquery.server.HaqRoute::new");
		$»spos = $GLOBALS['%s']->length;
		if($path === "index.php" || $path === "index") {
			php_Web::redirect("/");
			php_Sys::hexit(0);
		}
		if(_hx_ends_with($path, "/index")) {
			php_Web::redirect(_hx_substr($path, 0, strlen($path) - strlen("/index")));
			php_Sys::hexit(0);
		}
		if(file_exists($path) && _hx_ends_with($path, ".php")) {
			$this->routeType = haquery_server_HaqRouteType::$file;
			$this->pagePath = $path;
		} else {
			$path = trim($path, "/");
			if($path === "") {
				$path = "index";
			}
			$path = "pages/" . $path;
			$pageID = null;
			if(!haquery_server_HaqRoute::isPageExist($path)) {
				$p = _hx_explode("/", $path);
				$pageID = $p->pop();
				$path = $p->join("/");
			}
			if(!haquery_server_HaqRoute::isPageExist($path)) {
				php_Web::setReturnCode(404);
				php_Sys::hexit(0);
			}
			$this->pagePath = $path;
			$this->className = str_replace("/", ".", $path) . ".Server";
			if(Type::resolveClass($this->className) === null) {
				$this->className = "haquery.server.HaqPage";
			}
			$this->templatePath = haquery_server_HaqRoute_0($this, $pageID, $path);
		}
		$GLOBALS['%s']->pop();
	}}
	public $routeType;
	public $pagePath;
	public $className;
	public $templatePath;
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
			$»tmp = file_exists($path . "template.phtml") || Type::resolveClass(str_replace("/", ".", $path) . "Server") !== null;
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'haquery.server.HaqRoute'; }
}
function haquery_server_HaqRoute_0(&$»this, &$pageID, &$path) {
	if(file_exists($path . "/template.phtml")) {
		return $path . "/template.phtml";
	}
}
