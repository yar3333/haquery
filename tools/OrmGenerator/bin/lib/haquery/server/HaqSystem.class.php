<?php

class haquery_server_HaqSystem {
	public function __construct($route) { if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("haquery.server.HaqSystem::new");
		$»spos = $GLOBALS['%s']->length;
		$beginTime = Date::now()->getTime();
		haxe_Log::trace(null, _hx_anonymous(array("fileName" => "HaqSystem.hx", "lineNumber" => 29, "className" => "haquery.server.HaqSystem", "methodName" => "new")));
		haxe_Log::trace("init(" . $route->pagePath . ") " . "\x0AHTTP_HOST = " . $_SERVER['HTTP_HOST'] . "\x0AclientIP = " . $_SERVER['REMOTE_ADDR'], _hx_anonymous(array("fileName" => "HaqSystem.hx", "lineNumber" => 30, "className" => "haquery.server.HaqSystem", "methodName" => "new")));
		haquery_server_HaqProfiler::begin("HaqSystem::init(): build components");
		$templates = new haquery_server_HaqTemplates(haquery_base_HaQuery::$config->componentsFolders);
		haquery_server_HaqProfiler::end();
		haquery_base_HaQuery::$isPostback = haquery_server_HaqSystem_0($this, $beginTime, $route, $templates);
		$params = php_Web::getParams();
		if($route->pageID !== null) {
			$params->set("pageID", $route->pageID);
		}
		haquery_server_HaqProfiler::begin("HaqSystem::init(): page template");
		$pageInfo = haquery_server_HaqTemplates::parseComponent($route->pagePath);
		haquery_server_HaqProfiler::end();
		haquery_server_HaqProfiler::begin("HaqSystem::init(): page construct");
		$manager = new haquery_server_HaqComponentManager($templates);
		$page = $manager->createPage(Type::resolveClass($route->className), $pageInfo->doc, $params);
		haquery_server_HaqProfiler::end();
		if(!haquery_base_HaQuery::$isPostback) {
			haquery_server_HaqProfiler::begin("HaqSystem::init(): page render");
			$page->forEachComponent("preRender", null);
			$html = $page->render();
			haquery_server_HaqProfiler::end();
			haquery_server_HaqProfiler::begin("HaqSystem::init(): insert html and javascripts to <head>");
			$incCss = Lambda::map($templates->getStyleFilePaths(), array(new _hx_lambda(array(&$beginTime, &$html, &$manager, &$page, &$pageInfo, &$params, &$route, &$templates), "haquery_server_HaqSystem_1"), 'execute'))->join("\x0A        ") . (haquery_server_HaqSystem_2($this, $beginTime, $html, $manager, $page, $pageInfo, $params, $route, $templates));
			$incJs = _hx_deref(new _hx_array(array(haquery_server_HaqSystem::getScriptLink("support/jquery.js"), haquery_server_HaqSystem::getScriptLink("support/haquery.js"))))->join("\x0A        ");
			$html = str_replace("{styles}", $incCss, $html);
			$html = str_replace("{scripts}", $incJs, $html);
			$reCloseBody = new EReg("\\s*</body>", "");
			$closeBodyTagPos = haquery_server_HaqSystem_3($this, $beginTime, $html, $incCss, $incJs, $manager, $page, $pageInfo, $params, $reCloseBody, $route, $templates);
			$html = _hx_substr($html, 0, $closeBodyTagPos) . "\x0A\x0A" . "        <script>\x0A" . "            if(typeof haquery=='undefined') alert('haquery.js must be loaded!');\x0A" . "            " . str_replace("\x0A", "\x0A            ", $templates->getInternalDataForPageHtml()) . "\x0A" . "            " . str_replace("\x0A", "\x0A            ", $manager->getInternalDataForPageHtml()) . "\x0A" . "            haquery.base.HaQuery.run();\x0A" . "        </script>\x0A" . _hx_substr($html, $closeBodyTagPos, null);
			haquery_server_HaqProfiler::end();
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
				haquery_base_HaQuery::error("Component id = '" . $componentID . "' not found!", _hx_anonymous(array("fileName" => "HaqSystem.hx", "lineNumber" => 124, "className" => "haquery.server.HaqSystem", "methodName" => "new")));
			}
			$handler = $controlID . "_" . php_Web::getParams()->get("HAQUERY_EVENT");
			Reflect::callMethod($component, $handler, null);
			haxe_Log::trace("HAQUERY_OK" . haquery_server_HaqInternals::getAjaxAnswer(), _hx_anonymous(array("fileName" => "HaqSystem.hx", "lineNumber" => 128, "className" => "haquery.server.HaqSystem", "methodName" => "new")));
			header("Content-Type" . ": " . "text/plain; charset=utf-8");
			php_Lib::hprint("HAQUERY_OK" . haquery_server_HaqInternals::getAjaxAnswer());
		}
		$endTime = Date::now()->getTime();
		haxe_Log::trace(sprintf("page rendered %.3f s", $endTime - $beginTime), _hx_anonymous(array("fileName" => "HaqSystem.hx", "lineNumber" => 134, "className" => "haquery.server.HaqSystem", "methodName" => "new")));
		if(haquery_base_HaQuery::$config->isTraceProfiler) {
			haxe_Log::trace("profiler info:\x0A" . haquery_server_HaqProfiler::getResults(), _hx_anonymous(array("fileName" => "HaqSystem.hx", "lineNumber" => 138, "className" => "haquery.server.HaqSystem", "methodName" => "new")));
			haquery_server_HaqProfiler::saveTotalResults();
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
function haquery_server_HaqSystem_0(&$»this, &$beginTime, &$route, &$templates) {
	if(php_Web::getParams()->get("HAQUERY_POSTBACK") !== null) {
		return true;
	} else {
		return false;
	}
}
function haquery_server_HaqSystem_1(&$beginTime, &$html, &$manager, &$page, &$pageInfo, &$params, &$route, &$templates, $path) {
	{
		$GLOBALS['%s']->push("haquery.server.HaqSystem::new@75");
		$»spos2 = $GLOBALS['%s']->length;
		{
			$»tmp = haquery_server_HaqSystem::getCssLink($path);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
}
function haquery_server_HaqSystem_2(&$»this, &$beginTime, &$html, &$manager, &$page, &$pageInfo, &$params, &$route, &$templates) {
	if($pageInfo->css !== "") {
		return "\x0A      <style>" . $pageInfo->css . "</style>";
	} else {
		return "";
	}
}
function haquery_server_HaqSystem_3(&$»this, &$beginTime, &$html, &$incCss, &$incJs, &$manager, &$page, &$pageInfo, &$params, &$reCloseBody, &$route, &$templates) {
	if($reCloseBody->match($html)) {
		return $reCloseBody->matchedPos()->pos;
	} else {
		return strlen($html);
	}
}
