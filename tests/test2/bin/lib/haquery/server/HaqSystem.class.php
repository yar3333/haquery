<?php

class haquery_server_HaqSystem {
	public function __construct($route) { if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("haquery.server.HaqSystem::new");
		$»spos = $GLOBALS['%s']->length;
		$startTime = Date::now()->getTime();
		haxe_Log::trace(null, _hx_anonymous(array("fileName" => "HaqSystem.hx", "lineNumber" => 21, "className" => "haquery.server.HaqSystem", "methodName" => "new")));
		haxe_Log::trace("HAQUERY START route.pagePath = " . $route->pagePath . ", HTTP_HOST = " . $_SERVER['HTTP_HOST'] . ", clientIP = " . $_SERVER['REMOTE_ADDR'], _hx_anonymous(array("fileName" => "HaqSystem.hx", "lineNumber" => 22, "className" => "haquery.server.HaqSystem", "methodName" => "new")));
		HaqProfiler::begin("HaqSystem::init(): build components");
		$templates = new haquery_server_HaqTemplates(haquery_base_HaQuery::$config->componentsFolders);
		HaqProfiler::end();
		haquery_base_HaQuery::$isPostback = haquery_server_HaqSystem_0($this, $route, $startTime, $templates);
		$params = php_Web::getParams();
		if($route->pageID !== null) {
			$params->set("pageID", $route->pageID);
		}
		HaqProfiler::begin("HaqSystem::init(): page template");
		$pageInfo = haquery_server_HaqTemplates::parseComponent($route->pagePath);
		HaqProfiler::end();
		HaqProfiler::begin("HaqSystem::init(): page construct");
		$manager = new haquery_server_HaqComponentManager($templates);
		$page = $manager->createPage(Type::resolveClass($route->className), $pageInfo->doc, $params);
		HaqProfiler::end();
		if(!haquery_base_HaQuery::$isPostback) {
			HaqProfiler::begin("HaqSystem::init(): page render");
			$page->forEachComponent("preRender", null);
			$html = $page->render();
			HaqProfiler::end();
			HaqProfiler::begin("HaqSystem::init(): insert html and javascripts to <head>");
			$incCss = Lambda::map($templates->getStyleFilePaths(), array(new _hx_lambda(array(&$html, &$manager, &$page, &$pageInfo, &$params, &$route, &$startTime, &$templates), "haquery_server_HaqSystem_1"), 'execute'))->join("\x0A        ") . (haquery_server_HaqSystem_2($this, $html, $manager, $page, $pageInfo, $params, $route, $startTime, $templates));
			$incJs = _hx_deref(new _hx_array(array(haquery_server_HaqSystem::getScriptLink("haquery/client/jquery.js"), haquery_server_HaqSystem::getScriptLink("haquery/client/haquery.js"))))->join("\x0A        ");
			$html = str_replace("{styles}", $incCss, $html);
			$html = str_replace("{scripts}", $incJs, $html);
			$reCloseBody = new EReg("\\s*</body>", "");
			$closeBodyTagPos = haquery_server_HaqSystem_3($this, $html, $incCss, $incJs, $manager, $page, $pageInfo, $params, $reCloseBody, $route, $startTime, $templates);
			$html = _hx_substr($html, 0, $closeBodyTagPos) . "\x0A\x0A" . "        <script>\x0A" . "            if(typeof haquery=='undefined') alert('haquery.js must be loaded!');\x0A" . "            " . str_replace("\x0A", "\x0A            ", $templates->getInternalDataForPageHtml()) . "\x0A" . "            " . str_replace("\x0A", "\x0A            ", $manager->getInternalDataForPageHtml()) . "\x0A" . "            haquery.base.HaQuery.run();\x0A" . "        </script>\x0A" . _hx_substr($html, $closeBodyTagPos, null);
			HaqProfiler::end();
			header("Content-Type" . ": " . $page->contentType);
			php_Lib::hprint($html);
		} else {
			$page->forEachComponent("preEventHandlers", null);
			$controlID = php_Web::getParams()->get("HAQUERY_ID");
			$componentID = "";
			$n = _hx_last_index_of($controlID, "-", null);
			if($n > 0) {
				$componentID = _hx_substr($controlID, 0, $n);
				$controlID = _hx_substr($controlID, $n + 1, null);
			}
			$component = $page->findComponent($componentID);
			if($component === null) {
				throw new HException("Component id = '" . $componentID . "' not found.");
			}
			$handler = $controlID . "_" . php_Web::getParams()->get("HAQUERY_EVENT");
			Reflect::callMethod($component, $handler, null);
			haxe_Log::trace("HAQUERY_OK" . haquery_server_HaqInternals::getAjaxAnswer(), _hx_anonymous(array("fileName" => "HaqSystem.hx", "lineNumber" => 114, "className" => "haquery.server.HaqSystem", "methodName" => "new")));
			header("Content-Type" . ": " . "text/plain; charset=utf-8");
			php_Lib::hprint("HAQUERY_OK" . haquery_server_HaqInternals::getAjaxAnswer());
		}
		haxe_Log::trace(sprintf("HAQUERY FINISH %.5f s", Date::now()->getTime() - $startTime), _hx_anonymous(array("fileName" => "HaqSystem.hx", "lineNumber" => 119, "className" => "haquery.server.HaqSystem", "methodName" => "new")));
		if(haquery_base_HaQuery::$config->isTraceProfiler) {
			haxe_Log::trace("profiler info:\x0A" . HaqProfiler::getResults(), _hx_anonymous(array("fileName" => "HaqSystem.hx", "lineNumber" => 123, "className" => "haquery.server.HaqSystem", "methodName" => "new")));
			HaqProfiler::saveTotalResults();
		}
		$GLOBALS['%s']->pop();
	}}
	static function getScriptLink($path) {
		$GLOBALS['%s']->push("haquery.server.HaqSystem::getScriptLink");
		$»spos = $GLOBALS['%s']->length;
		$url = haquery_base_HaQuery::path2url($path) . "?" . php_FileSystem::stat($path)->mtime->getTime();
		{
			$»tmp = "<script src='" . $url . "'></script>";
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getCssLink($path) {
		$GLOBALS['%s']->push("haquery.server.HaqSystem::getCssLink");
		$»spos = $GLOBALS['%s']->length;
		$url = haquery_base_HaQuery::path2url($path) . "?" . php_FileSystem::stat($path)->mtime->getTime();
		{
			$»tmp = "<link rel='stylesheet' type='text/css' href='" . $url . "' />";
			$GLOBALS['%s']->pop();
			return $»tmp;
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
function haquery_server_HaqSystem_1(&$html, &$manager, &$page, &$pageInfo, &$params, &$route, &$startTime, &$templates, $path) {
	{
		$GLOBALS['%s']->push("haquery.server.HaqSystem::new@61");
		$»spos2 = $GLOBALS['%s']->length;
		{
			$»tmp = haquery_server_HaqSystem::getCssLink($path);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
}
function haquery_server_HaqSystem_2(&$»this, &$html, &$manager, &$page, &$pageInfo, &$params, &$route, &$startTime, &$templates) {
	if($pageInfo->css !== "") {
		return "\x0A      <style>" . $pageInfo->css . "</style>";
	} else {
		return "";
	}
}
function haquery_server_HaqSystem_3(&$»this, &$html, &$incCss, &$incJs, &$manager, &$page, &$pageInfo, &$params, &$reCloseBody, &$route, &$startTime, &$templates) {
	if($reCloseBody->match($html)) {
		return $reCloseBody->matchedPos()->pos;
	} else {
		return strlen($html);
	}
}
