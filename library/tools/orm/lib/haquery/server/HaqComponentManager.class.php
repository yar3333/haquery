<?php

class haquery_server_HaqComponentManager {
	public function __construct($templates) {
		if(!php_Boot::$skip_constructor) {
		$this->templates = $templates;
		$this->registeredScripts = new _hx_array(array());
		$this->registeredStyles = new _hx_array(array());
	}}
	public $templates;
	public $registeredScripts;
	public $registeredStyles;
	public function newComponent($parent, $clas, $name, $id, $doc, $attr, $parentNode) {
		null;
		$r = Type::createInstance($clas, new _hx_array(array()));
		$r->construct($this, $parent, $name, $id, $doc, $attr, $parentNode);
		null;
		return $r;
	}
	public function createComponent($parent, $tagOrName, $id, $attr, $parentNode) {
		$name = ((StringTools::startsWith($tagOrName, "haq:")) ? $this->getNameByTag($tagOrName) : $tagOrName);
		$template = $this->templates->get($name);
		$component = $this->newComponent($parent, $template->serverClass, $name, $id, $template->doc, $attr, $parentNode);
		return $component;
	}
	public function createPage($path, $attr) {
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
		return $page;
	}
	public function registerScript($tag, $supportRelatedPath) {
		$path = $this->templates->getSupportPath($tag) . $supportRelatedPath;
		if(!Lambda::has($this->registeredScripts, $path, null)) {
			$this->registeredScripts->push($path);
		}
	}
	public function registerStyle($tag, $supportRelatedPath) {
		$path = $this->templates->getSupportPath($tag) . $supportRelatedPath;
		if(!Lambda::has($this->registeredStyles, $path, null)) {
			$this->registeredStyles->push($path);
		}
	}
	public function getRegisteredScripts() {
		return $this->registeredScripts;
	}
	public function getRegisteredStyles() {
		return $this->registeredStyles;
	}
	public function getInternalDataForPageHtml($page, $path) {
		$s = "";
		$tags = $this->templates->getTags();
		$s .= "haquery.client.HaqInternals.tags = [\x0A";
		$tagComponents = $this->getTagComponents($page);
		if(null == $tagComponents) throw new HException('null iterable');
		$»it = $tagComponents->keys();
		while($»it->hasNext()) {
			$tag = $»it->next();
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
		return $s;
	}
	public function getTagComponents($page) {
		$r = new Hash();
		$this->getTagComponents_fill($page, $r);
		return $r;
	}
	public function getTagComponents_fill($component, $r) {
		if(null == $component->components) throw new HException('null iterable');
		$»it = $component->components->iterator();
		while($»it->hasNext()) {
			$child = $»it->next();
			$tag = $child->tag;
			if(!$r->exists($tag)) {
				$r->set($tag, new _hx_array(array()));
			}
			$r->get($child->tag)->push($child);
			$this->getTagComponents_fill($child, $r);
			unset($tag);
		}
	}
	public function getSupportPath($tag) {
		return $this->templates->getSupportPath($tag);
	}
	public function getNameByTag($tag) {
		if(!StringTools::startsWith($tag, "haq:")) {
			throw new HException("Component tag '" . $tag . "' must started with 'haq:' prefix.");
		}
		return _hx_explode("-", strtolower(_hx_substr($tag, strlen("haq:"), null)))->join("_");
	}
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
	function __toString() { return 'haquery.server.HaqComponentManager'; }
}
function haquery_server_HaqComponentManager_0(&$components, &$page, &$path, &$s, &$tag, &$tagComponents, &$tags, $x) {
	{
		while($x !== null) {
			if(!$x->visible) {
				return false;
			}
			$x = $x->parent;
		}
		return true;
	}
}
function haquery_server_HaqComponentManager_1(&$components, &$page, &$path, &$s, &$tag, &$tagComponents, &$tags, &$visibledComponents, $x) {
	{
		return $x->fullID;
	}
}
