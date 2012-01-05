<?php

class haquery_server_HaqComponentManager {
	public function __construct($templates) {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::new");
		$�spos = $GLOBALS['%s']->length;
		$this->templates = $templates;
		$this->registeredScripts = new _hx_array(array());
		$this->registeredStyles = new _hx_array(array());
		$GLOBALS['%s']->pop();
	}}
	public $templates;
	public $registeredScripts;
	public $registeredStyles;
	public function newComponent($parent, $clas, $name, $id, $doc, $attr, $parentNode) {
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::newComponent");
		$�spos = $GLOBALS['%s']->length;
		null;
		$r = Type::createInstance($clas, new _hx_array(array()));
		$r->construct($this, $parent, $name, $id, $doc, $attr, $parentNode);
		null;
		{
			$GLOBALS['%s']->pop();
			return $r;
		}
		$GLOBALS['%s']->pop();
	}
	public function createComponent($parent, $tagOrName, $id, $attr, $parentNode) {
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::createComponent");
		$�spos = $GLOBALS['%s']->length;
		$name = ((StringTools::startsWith($tagOrName, "haq:")) ? $this->getNameByTag($tagOrName) : $tagOrName);
		$template = $this->templates->get($name);
		$component = $this->newComponent($parent, $template->serverClass, $name, $id, $template->doc, $attr, $parentNode);
		{
			$GLOBALS['%s']->pop();
			return $component;
		}
		$GLOBALS['%s']->pop();
	}
	public function createPage($path, $attr) {
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::createPage");
		$�spos = $GLOBALS['%s']->length;
		$className = str_replace("/", ".", $path) . ".Server";
		$standardPageClass = Type::resolveClass("haquery.server.HaqPage");
		$pageClass = Type::resolveClass($className);
		if($pageClass === null) {
			$pageClass = $standardPageClass;
		} else {
			if(!haquery_base_HaqTools::isClassHasSuperClass($pageClass, $standardPageClass)) {
				throw new HException("Class '" . $className . "' must be inherited from '" . Type::getClassName($standardPageClass) . "'.");
			}
		}
		$doc = $this->templates->getPageTemplateDoc($path);
		$page = $this->newComponent(null, $pageClass, "", "", $doc, $attr, null);
		{
			$GLOBALS['%s']->pop();
			return $page;
		}
		$GLOBALS['%s']->pop();
	}
	public function registerScript($tag, $supportRelatedPath) {
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::registerScript");
		$�spos = $GLOBALS['%s']->length;
		$path = $this->templates->getSupportPath($tag) . $supportRelatedPath;
		if(!Lambda::has($this->registeredScripts, $path, null)) {
			$this->registeredScripts->push($path);
		}
		$GLOBALS['%s']->pop();
	}
	public function registerStyle($tag, $supportRelatedPath) {
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::registerStyle");
		$�spos = $GLOBALS['%s']->length;
		$path = $this->templates->getSupportPath($tag) . $supportRelatedPath;
		if(!Lambda::has($this->registeredStyles, $path, null)) {
			$this->registeredStyles->push($path);
		}
		$GLOBALS['%s']->pop();
	}
	public function getRegisteredScripts() {
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::getRegisteredScripts");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = $this->registeredScripts;
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function getRegisteredStyles() {
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::getRegisteredStyles");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = $this->registeredStyles;
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function getInternalDataForPageHtml($page, $path) {
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::getInternalDataForPageHtml");
		$�spos = $GLOBALS['%s']->length;
		$s = "";
		$tags = $this->templates->getTags();
		$s .= "haquery.client.HaqInternals.tags = [\x0A";
		$tagComponents = $this->getTagComponents($page);
		if(null == $tagComponents) throw new HException('null iterable');
		$�it = $tagComponents->keys();
		while($�it->hasNext()) {
			$tag = $�it->next();
			$components = $tagComponents->get($tag);
			$visibledComponents = Lambda::filter($components, array(new _hx_lambda(array(&$components, &$page, &$path, &$s, &$tag, &$tagComponents, &$tags), "haquery_server_HaqComponentManager_0"), 'execute'));
			$ids = Lambda::map($visibledComponents, array(new _hx_lambda(array(&$components, &$page, &$path, &$s, &$tag, &$tagComponents, &$tags, &$visibledComponents), "haquery_server_HaqComponentManager_1"), 'execute'))->join(",");
			$s .= "    ['" . $tag . "', '" . $ids . "'],\x0A";
			unset($visibledComponents,$ids,$components);
		}
		$s = rtrim($s, "\x0A,") . "\x0A];\x0A";
		$serverHandlers = new Hash();
		$serverHandlers->set("", $this->templates->parseServerHandlers($path));
		{
			$_g = 0;
			while($_g < $tags->length) {
				$tag = $tags[$_g];
				++$_g;
				$serverHandlers->set($tag, $this->templates->get($tag)->serverHandlers);
				unset($tag);
			}
		}
		$s .= "haquery.client.HaqInternals.serializedServerHandlers = \"" . haxe_Serializer::run($serverHandlers) . "\";\x0A";
		$s .= "haquery.client.HaqInternals.pagePackage = \"" . str_replace("/", ".", $path) . "\";";
		{
			$GLOBALS['%s']->pop();
			return $s;
		}
		$GLOBALS['%s']->pop();
	}
	public function getTagComponents($page) {
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::getTagComponents");
		$�spos = $GLOBALS['%s']->length;
		$r = new Hash();
		$this->getTagComponents_fill($page, $r);
		{
			$GLOBALS['%s']->pop();
			return $r;
		}
		$GLOBALS['%s']->pop();
	}
	public function getTagComponents_fill($component, $r) {
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::getTagComponents_fill");
		$�spos = $GLOBALS['%s']->length;
		if(null == $component->components) throw new HException('null iterable');
		$�it = $component->components->iterator();
		while($�it->hasNext()) {
			$child = $�it->next();
			$tag = $child->tag;
			if(!$r->exists($tag)) {
				$r->set($tag, new _hx_array(array()));
			}
			$r->get($child->tag)->push($child);
			$this->getTagComponents_fill($child, $r);
			unset($tag);
		}
		$GLOBALS['%s']->pop();
	}
	public function getSupportPath($tag) {
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::getSupportPath");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = $this->templates->getSupportPath($tag);
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function getNameByTag($tag) {
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::getNameByTag");
		$�spos = $GLOBALS['%s']->length;
		if(!StringTools::startsWith($tag, "haq:")) {
			throw new HException("Component tag '" . $tag . "' must started with 'haq:' prefix.");
		}
		{
			$�tmp = _hx_explode("-", strtolower(_hx_substr($tag, strlen("haq:"), null)))->join("_");
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function __call($m, $a) {
		if(isset($this->$m) && is_callable($this->$m))
			return call_user_func_array($this->$m, $a);
		else if(isset($this->�dynamics[$m]) && is_callable($this->�dynamics[$m]))
			return call_user_func_array($this->�dynamics[$m], $a);
		else if('toString' == $m)
			return $this->__toString();
		else
			throw new HException('Unable to call �'.$m.'�');
	}
	function __toString() { return 'haquery.server.HaqComponentManager'; }
}
function haquery_server_HaqComponentManager_0(&$components, &$page, &$path, &$s, &$tag, &$tagComponents, &$tags, $x) {
	$�spos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::getInternalDataForPageHtml@112");
		$�spos2 = $GLOBALS['%s']->length;
		while($x !== null) {
			if(!$x->visible) {
				$GLOBALS['%s']->pop();
				return false;
			}
			$x = $x->parent;
		}
		{
			$GLOBALS['%s']->pop();
			return true;
		}
		$GLOBALS['%s']->pop();
	}
}
function haquery_server_HaqComponentManager_1(&$components, &$page, &$path, &$s, &$tag, &$tagComponents, &$tags, &$visibledComponents, $x) {
	$�spos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::getInternalDataForPageHtml@120");
		$�spos2 = $GLOBALS['%s']->length;
		{
			$�tmp = $x->fullID;
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
}