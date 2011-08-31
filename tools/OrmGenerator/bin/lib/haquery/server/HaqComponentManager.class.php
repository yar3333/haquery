<?php

class haquery_server_HaqComponentManager {
	public function __construct($templates) {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::new");
		$製pos = $GLOBALS['%s']->length;
		$this->templates = $templates;
		$this->tag_id_component = new Hash();
		$this->registeredScripts = new _hx_array(array());
		$this->registeredStyles = new _hx_array(array());
		$GLOBALS['%s']->pop();
	}}
	public $templates;
	public $tag_id_component;
	public $registeredScripts;
	public $registeredStyles;
	public function newComponent($parent, $clas, $name, $id, $doc, $attr, $innerHTML) {
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::newComponent");
		$製pos = $GLOBALS['%s']->length;
		$r = Type::createInstance($clas, new _hx_array(array()));
		$r->construct($this, $parent, $name, $id, $doc, $attr, $innerHTML);
		{
			$GLOBALS['%s']->pop();
			return $r;
		}
		$GLOBALS['%s']->pop();
	}
	public function createComponent($parent, $tagOrName, $id, $attr, $innerHTML) {
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::createComponent");
		$製pos = $GLOBALS['%s']->length;
		$name = haquery_server_HaqComponentManager_0($this, $attr, $id, $innerHTML, $parent, $tagOrName);
		$template = $this->templates->get($name);
		$component = $this->newComponent($parent, $template->serverClass, $name, $id, $template->doc, $attr, $innerHTML);
		if(!$this->tag_id_component->exists($name)) {
			$this->tag_id_component->set($name, new _hx_array(array()));
		}
		$this->tag_id_component->get($name)->push($component);
		{
			$GLOBALS['%s']->pop();
			return $component;
		}
		$GLOBALS['%s']->pop();
	}
	public function createPage($path, $attr) {
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::createPage");
		$製pos = $GLOBALS['%s']->length;
		$className = str_replace("/", ".", $path) . ".Server";
		if(Type::resolveClass($className) === null) {
			$className = "haquery.server.HaqPage";
		}
		$pageClass = Type::resolveClass($className);
		$doc = haquery_server_HaqTemplates::getPageTemplateDoc($path);
		$page = $this->newComponent(null, $pageClass, "", "", $doc, $attr, null);
		{
			$GLOBALS['%s']->pop();
			return $page;
		}
		$GLOBALS['%s']->pop();
	}
	public function registerScript($tag, $url) {
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::registerScript");
		$製pos = $GLOBALS['%s']->length;
		$url = $this->templates->getFileUrl($tag, haquery_base_HaQuery::$folders->support) . "/" . $url;
		if($this->registeredScripts->indexOf($url) === -1) {
			$this->registeredScripts->push($url);
		}
		$GLOBALS['%s']->pop();
	}
	public function registerStyle($tag, $url) {
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::registerStyle");
		$製pos = $GLOBALS['%s']->length;
		$url = $this->templates->getFileUrl($tag, haquery_base_HaQuery::$folders->support) . "/" . $url;
		if($this->registeredStyles->indexOf($url) === -1) {
			$this->registeredStyles->push($url);
		}
		$GLOBALS['%s']->pop();
	}
	public function getRegisteredScripts() {
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::getRegisteredScripts");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = $this->registeredScripts;
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	public function getRegisteredStyles() {
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::getRegisteredStyles");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = $this->registeredStyles;
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	public function getInternalDataForPageHtml($path) {
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::getInternalDataForPageHtml");
		$製pos = $GLOBALS['%s']->length;
		$s = "";
		$tags = $this->templates->getTags();
		$s .= "haquery.client.HaqInternals.tags = [\x0A";
		if(null == $this->tag_id_component) throw new HException('null iterable');
		$蜴t = $this->tag_id_component->keys();
		while($蜴t->hasNext()) {
			$tag = $蜴t->next();
			$components = $this->tag_id_component->get($tag);
			$ids = Lambda::map($components, array(new _hx_lambda(array(&$components, &$path, &$s, &$tag, &$tags), "haquery_server_HaqComponentManager_1"), 'execute'))->join(",");
			$s .= "    ['" . $tag . "', '" . $ids . "'],\x0A";
			unset($ids,$components);
		}
		$s = rtrim($s, "\x0A,") . "\x0A];\x0A";
		$serverHandlers = new Hash();
		$serverHandlers->set("", haquery_server_HaqTemplates::parseServerHandlers($path));
		{
			$_g = 0;
			while($_g < $tags->length) {
				$tag = $tags[$_g];
				++$_g;
				$serverHandlers->set($tag, $this->templates->get($tag)->serverHandlers);
				unset($tag);
			}
		}
		$s .= "haquery.client.HaqInternals.serializedServerHandlers = \"" . haxe_Serializer::run($serverHandlers) . "\";";
		{
			$GLOBALS['%s']->pop();
			return $s;
		}
		$GLOBALS['%s']->pop();
	}
	public function getSupportPath($tag) {
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::getSupportPath");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = $this->templates->getFileUrl($tag, haquery_base_HaQuery::$folders->support) . "/";
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	public function getNameByTag($tag) {
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::getNameByTag");
		$製pos = $GLOBALS['%s']->length;
		if(!_hx_starts_with($tag, "haq:")) {
			throw new HException("Component tag '" . $tag . "' must started with 'haq:' prefix.");
		}
		{
			$裨mp = _hx_explode("-", strtolower(_hx_substr($tag, strlen("haq:"), null)))->join("_");
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	public function __call($m, $a) {
		if(isset($this->$m) && is_callable($this->$m))
			return call_user_func_array($this->$m, $a);
		else if(isset($this->蜿ynamics[$m]) && is_callable($this->蜿ynamics[$m]))
			return call_user_func_array($this->蜿ynamics[$m], $a);
		else if('toString' == $m)
			return $this->__toString();
		else
			throw new HException('Unable to call �'.$m.'�');
	}
	function __toString() { return 'haquery.server.HaqComponentManager'; }
}
function haquery_server_HaqComponentManager_0(&$裨his, &$attr, &$id, &$innerHTML, &$parent, &$tagOrName) {
	if(_hx_starts_with($tagOrName, "haq:")) {
		return $裨his->getNameByTag($tagOrName);
	} else {
		return $tagOrName;
	}
}
function haquery_server_HaqComponentManager_1(&$components, &$path, &$s, &$tag, &$tags, $x) {
	{
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::getInternalDataForPageHtml@91");
		$製pos2 = $GLOBALS['%s']->length;
		{
			$裨mp = $x->fullID;
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
}
