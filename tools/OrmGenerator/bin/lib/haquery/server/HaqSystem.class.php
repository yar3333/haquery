<?php

class haquery_server_HaqSystem {
	public function __construct($route) { if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("haquery.server.HaqSystem::new");
		$»spos = $GLOBALS['%s']->length;
		$startTime = Date::now()->getTime();
		haxe_Log::trace(null, _hx_anonymous(array("fileName" => "HaqSystem.hx", "lineNumber" => 21, "className" => "haquery.server.HaqSystem", "methodName" => "new")));
		haxe_Log::trace("HAQUERY START route.pagePath = " . $route->path . ", HTTP_HOST = " . $_SERVER['HTTP_HOST'] . ", clientIP = " . $_SERVER['REMOTE_ADDR'], _hx_anonymous(array("fileName" => "HaqSystem.hx", "lineNumber" => 22, "className" => "haquery.server.HaqSystem", "methodName" => "new")));
		HaqProfiler::begin("HaqSystem::init(): build components");
		$templates = new haquery_server_HaqTemplates(haquery_base_HaQuery::$config->componentsFolders);
		HaqProfiler::end();
		haquery_base_HaQuery::$isPostback = haquery_server_HaqSystem_0($this, $route, $startTime, $templates);
		$params = php_Web::getParams();
		if($route->pageID !== null) {
			$params->set("pageID", $route->pageID);
		}
		HaqProfiler::begin("HaqSystem::init(): page construct");
		$manager = new haquery_server_HaqComponentManager($templates);
		$page = $manager->createPage($route->path, $params);
		HaqProfiler::end();
		$html = null;
		if(!haquery_base_HaQuery::$isPostback) {
			$html = haquery_server_HaqSystem::renderPage($page, $templates, $manager, $route->path);
		} else {
			$html = $this->renderAjax($page);
		}
		haxe_Log::trace(sprintf("HAQUERY FINISH %.5f s", Date::now()->getTime() - $startTime), _hx_anonymous(array("fileName" => "HaqSystem.hx", "lineNumber" => 51, "className" => "haquery.server.HaqSystem", "methodName" => "new")));
		if(haquery_base_HaQuery::$config->isTraceProfiler) {
			haxe_Log::trace("profiler info:\x0A" . HaqProfiler::getResults(), _hx_anonymous(array("fileName" => "HaqSystem.hx", "lineNumber" => 55, "className" => "haquery.server.HaqSystem", "methodName" => "new")));
			HaqProfiler::saveTotalResults();
		}
		php_Lib::hprint($html);
		$GLOBALS['%s']->pop();
	}}
	public function renderAjax($page) {
		$GLOBALS['%s']->push("haquery.server.HaqSystem::renderAjax");
		$»spos = $GLOBALS['%s']->length;
		$page->forEachComponent("preEventHandlers", null);
		$fullElemID = php_Web::getParams()->get("HAQUERY_ID");
		$n = _hx_last_index_of($fullElemID, "-", null);
		$componentID = haquery_server_HaqSystem_1($this, $fullElemID, $n, $page);
		$elemID = haquery_server_HaqSystem_2($this, $componentID, $fullElemID, $n, $page);
		$component = $page->findComponent($componentID);
		if($component === null) {
			throw new HException("Component id = '" . $componentID . "' not found.");
		}
		$component->callElemEventHandler($elemID, php_Web::getParams()->get("HAQUERY_EVENT"));
		header("Content-Type" . ": " . "text/plain; charset=utf-8");
		{
			$»tmp = "HAQUERY_OK" . haquery_server_HaqInternals::getAjaxAnswer();
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function renderPage($page, $templates, $manager, $path) {
		$GLOBALS['%s']->push("haquery.server.HaqSystem::renderPage");
		$»spos = $GLOBALS['%s']->length;
		HaqProfiler::begin("HaqSystem::init(): page render");
		$page->forEachComponent("preRender", null);
		$page->insertStyles($templates->getStyleFilePaths()->concat($manager->getRegisteredStyles()));
		$page->insertScripts(_hx_deref(new _hx_array(array("haquery/client/jquery.js", "haquery/client/haquery.js")))->concat($manager->getRegisteredScripts()));
		$page->insertInitInnerBlock("<script>\x0A" . "    if(typeof haquery=='undefined') alert('haquery.js must be loaded!');\x0A" . "    " . str_replace("\x0A", "\x0A    ", $templates->getInternalDataForPageHtml()) . "\x0A" . "    " . str_replace("\x0A", "\x0A    ", $manager->getInternalDataForPageHtml($path)) . "\x0A" . "    haquery.base.HaQuery.run();\x0A" . "</script>");
		$html = $page->render();
		HaqProfiler::end();
		header("Content-Type" . ": " . $page->contentType);
		{
			$GLOBALS['%s']->pop();
			return $html;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'haquery.server.HaqSystem'; }
}
function haquery_server_HaqSystem_0(&$»this, &$route, &$startTime, &$templates) {
	if(php_Web::getParams()->get("HAQUERY_POSTBACK") !== null) {
		return true;
	} else {
		return false;
	}
}
function haquery_server_HaqSystem_1(&$»this, &$fullElemID, &$n, &$page) {
	if($n > 0) {
		return _hx_substr($fullElemID, 0, $n);
	} else {
		return "";
	}
}
function haquery_server_HaqSystem_2(&$»this, &$componentID, &$fullElemID, &$n, &$page) {
	if($n > 0) {
		return _hx_substr($fullElemID, $n + 1, null);
	} else {
		return $fullElemID;
	}
}
