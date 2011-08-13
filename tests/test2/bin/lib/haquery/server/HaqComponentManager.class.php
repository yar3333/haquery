<?php

class haquery_server_HaqComponentManager {
	public function __construct($templates) {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::new");
		$»spos = $GLOBALS['%s']->length;
		$this->templates = $templates;
		$this->tag2id2component = new Hash();
		$GLOBALS['%s']->pop();
	}}
	public $templates;
	public $tag2id2component;
	public function newComponent($parent, $clas, $name, $id, $doc, $attr, $innerHTML) {
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::newComponent");
		$»spos = $GLOBALS['%s']->length;
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
		$»spos = $GLOBALS['%s']->length;
		$name = haquery_server_HaqComponentManager_0($this, $attr, $id, $innerHTML, $parent, $tagOrName);
		$template = $this->templates->get($name);
		$component = $this->newComponent($parent, $template->clas, $name, $id, $template->doc, $attr, $innerHTML);
		if(!$this->tag2id2component->exists($name)) {
			$this->tag2id2component->set($name, new _hx_array(array()));
		}
		$this->tag2id2component->get($name)->push($component);
		{
			$GLOBALS['%s']->pop();
			return $component;
		}
		$GLOBALS['%s']->pop();
	}
	public function createPage($clas, $doc, $attr) {
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::createPage");
		$»spos = $GLOBALS['%s']->length;
		haquery_server_HaqComponentManager::processPlaceholders($doc);
		$component = $this->newComponent(null, $clas, "", "", $doc, $attr, null);
		{
			$GLOBALS['%s']->pop();
			return $component;
		}
		$GLOBALS['%s']->pop();
	}
	public function getInternalDataForPageHtml() {
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::getInternalDataForPageHtml");
		$»spos = $GLOBALS['%s']->length;
		$tags = $this->templates->getTags();
		$s = "haquery.client.HaqInternals.serverHandlers = [\x0A";
		{
			$_g = 0;
			while($_g < $tags->length) {
				$tag = $tags[$_g];
				++$_g;
				$info = $this->templates->get($tag);
				if($info->serverHandlers->keys()->hasNext()) {
					$s .= "    ['" . $tag . "',\x0A";
					if(null == $info->serverHandlers) throw new HException('null iterable');
					$»it = $info->serverHandlers->keys();
					while($»it->hasNext()) {
						$id = $»it->next();
						$s .= "        ['" . $id . "', '" . $info->serverHandlers->get($id)->join(",") . "'],\x0A";
					}
					$s = rtrim($s, "\x0A,") . "\x0A    ],\x0A";
				}
				unset($tag,$info);
			}
		}
		$s = rtrim($s, "\x0A,") . "\x0A];\x0A";
		$s .= "haquery.client.HaqInternals.tags = [\x0A";
		if(null == $this->tag2id2component) throw new HException('null iterable');
		$»it = $this->tag2id2component->keys();
		while($»it->hasNext()) {
			$tag = $»it->next();
			$components = $this->tag2id2component->get($tag);
			$ids = Lambda::map($components, array(new _hx_lambda(array(&$components, &$s, &$tag, &$tags), "haquery_server_HaqComponentManager_1"), 'execute'))->join(",");
			$s .= "    ['" . $tag . "', '" . $ids . "'],\x0A";
			unset($ids,$components);
		}
		$s = rtrim($s, "\x0A,") . "\x0A];";
		{
			$GLOBALS['%s']->pop();
			return $s;
		}
		$GLOBALS['%s']->pop();
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
	static function getNameByTag($tag) {
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::getNameByTag");
		$»spos = $GLOBALS['%s']->length;
		if(!_hx_starts_with($tag, "haq:")) {
			throw new HException("Component tag '" . $tag . "' must started with 'haq:' prefix.");
		}
		{
			$»tmp = _hx_explode("-", strtolower(_hx_substr($tag, strlen("haq:"), null)))->join("_");
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function processPlaceholders($doc) {
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::processPlaceholders");
		$»spos = $GLOBALS['%s']->length;
		$placeholders = new _hx_array($doc->find("haq:placeholder"));
		$contents = new _hx_array($doc->find(">haq:content"));
		{
			$_g = 0;
			while($_g < $placeholders->length) {
				$ph = $placeholders[$_g];
				++$_g;
				$content = null;
				{
					$_g1 = 0;
					while($_g1 < $contents->length) {
						$c = $contents[$_g1];
						++$_g1;
						if($c->getAttribute("id") === $ph->getAttribute("id")) {
							$content = $c;
							break;
						}
						unset($c);
					}
					unset($_g1);
				}
				if($content !== null) {
					$ph->parent->replaceChildWithInner($ph, $content);
				} else {
					$ph->parent->replaceChildWithInner($ph, $ph);
				}
				unset($ph,$content);
			}
		}
		{
			$_g = 0;
			while($_g < $contents->length) {
				$c = $contents[$_g];
				++$_g;
				$c->remove();
				unset($c);
			}
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'haquery.server.HaqComponentManager'; }
}
function haquery_server_HaqComponentManager_0(&$»this, &$attr, &$id, &$innerHTML, &$parent, &$tagOrName) {
	if(_hx_starts_with($tagOrName, "haq:")) {
		return haquery_server_HaqComponentManager::getNameByTag($tagOrName);
	} else {
		return $tagOrName;
	}
}
function haquery_server_HaqComponentManager_1(&$components, &$s, &$tag, &$tags, $x) {
	{
		$GLOBALS['%s']->push("haquery.server.HaqComponentManager::getInternalDataForPageHtml@67");
		$»spos2 = $GLOBALS['%s']->length;
		{
			$»tmp = $x->fullID;
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
}
