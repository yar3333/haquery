<?php

class haquery_server_HaqSystem {
	public function __construct($route, $isPostback) { if(!php_Boot::$skip_constructor) {
		haxe_Log::trace(null, _hx_anonymous(array("fileName" => "HaqSystem.hx", "lineNumber" => 19, "className" => "haquery.server.HaqSystem", "methodName" => "new")));
		null;
		haxe_Log::trace("HAQUERY SYSTEM Start route.pagePath = " . $route->path . ", HTTP_HOST = " . haquery_server_Web::getHttpHost() . ", clientIP = " . $_SERVER['REMOTE_ADDR'] . ", pageID = " . $route->pageID, _hx_anonymous(array("fileName" => "HaqSystem.hx", "lineNumber" => 23, "className" => "haquery.server.HaqSystem", "methodName" => "new")));
		null;
		$templates = new haquery_server_HaqTemplates(haquery_server_HaqConfig::getComponentsFolders("", haquery_server_Lib::$config->componentsPackage));
		null;
		$params = php_Web::getParams();
		if($route->pageID !== null) {
			$params->set("pageID", $route->pageID);
		}
		$manager = new haquery_server_HaqComponentManager($templates);
		null;
		$page = $manager->createPage($route->path, $params);
		null;
		$html = null;
		if(!$isPostback) {
			$html = haquery_server_HaqSystem::renderPage($page, $templates, $manager, $route->path);
		} else {
			$html = $this->renderAjax($page);
		}
		haxe_Log::trace("HAQUERY SYSTEM Finish", _hx_anonymous(array("fileName" => "HaqSystem.hx", "lineNumber" => 51, "className" => "haquery.server.HaqSystem", "methodName" => "new")));
		null;
		php_Lib::hprint($html);
	}}
	public function renderAjax($page) {
		$page->forEachComponent("preEventHandlers", null);
		$fullElemID = php_Web::getParams()->get("HAQUERY_ID");
		$n = _hx_last_index_of($fullElemID, "-", null);
		$componentID = (($n > 0) ? _hx_substr($fullElemID, 0, $n) : "");
		$elemID = (($n > 0) ? _hx_substr($fullElemID, $n + 1, null) : $fullElemID);
		$component = $page->findComponent($componentID);
		if($component === null) {
			throw new HException("Component id = '" . $componentID . "' not found.");
		}
		$component->callElemEventHandler($elemID, php_Web::getParams()->get("HAQUERY_EVENT"));
		header("Content-Type" . ": " . "text/plain; charset=utf-8");
		return "HAQUERY_OK" . haquery_server_HaqInternals::getAjaxResponse();
	}
	static function renderPage($page, $templates, $manager, $path) {
		null;
		$page->forEachComponent("preRender", null);
		if(!haquery_server_Lib::$config->disablePageMetaData) {
			$page->insertStyles($templates->getStyleFilePaths()->concat($manager->getRegisteredStyles()));
			$page->insertScripts(_hx_deref(new _hx_array(array("haquery/client/jquery.js", "haquery/client/haquery.js")))->concat($manager->getRegisteredScripts()));
			$page->insertInitInnerBlock("<script>\x0A" . "    if(typeof haquery=='undefined') alert('haquery.js must be loaded!');\x0A" . "    " . str_replace("\x0A", "\x0A    ", $templates->getInternalDataForPageHtml()) . "\x0A" . "    " . str_replace("\x0A", "\x0A    ", $manager->getInternalDataForPageHtml($page, $path)) . "\x0A" . "    haquery.client.Lib.run();\x0A" . "</script>");
		}
		$html = $page->render();
		null;
		header("Content-Type" . ": " . $page->contentType);
		return $html;
	}
	function __toString() { return 'haquery.server.HaqSystem'; }
}
