<?php

class haquery_server_HaqComponent extends haquery_base_HaqComponent {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("haquery.server.HaqComponent::new");
		$»spos = $GLOBALS['%s']->length;
		parent::__construct();
		$this->visible = true;
		$GLOBALS['%s']->pop();
	}}
	public $manager;
	public $innerHTML;
	public $doc;
	public $visible;
	public $params;
	public function construct($manager, $parent, $tag, $id, $doc, $params, $innerHTML) {
		$GLOBALS['%s']->push("haquery.server.HaqComponent::construct");
		$»spos = $GLOBALS['%s']->length;
		parent::commonConstruct($parent,$tag,$id);
		$this->manager = $manager;
		$this->doc = $doc;
		$this->params = $params;
		$this->innerHTML = $innerHTML;
		$this->loadParamsToObjectFields();
		$this->createEvents();
		$this->createChildComponents();
		if(Reflect::isFunction(Reflect::field($this, "init"))) {
			Reflect::callMethod($this, Reflect::field($this, "init"), new _hx_array(array()));
		}
		$GLOBALS['%s']->pop();
	}
	public function loadParamsToObjectFields() {
		$GLOBALS['%s']->push("haquery.server.HaqComponent::loadParamsToObjectFields");
		$»spos = $GLOBALS['%s']->length;
		if(_hx_field($this, "params") !== null) {
			$restrictedFields = Reflect::fields(Type::createEmptyInstance(Type::resolveClass("haquery.server.HaqComponent")));
			$fields = new Hash();
			{
				$_g = 0; $_g1 = Reflect::fields($this);
				while($_g < $_g1->length) {
					$field = $_g1[$_g];
					++$_g;
					if(!Reflect::isFunction(Reflect::field($this, $field)) && !Lambda::has($restrictedFields, $field, null) && !StringTools::startsWith($field, "event_")) {
						$fields->set(strtolower($field), $field);
					}
					unset($field);
				}
			}
			if(Type::getClassName(Type::getClass($this->params)) === "Hash") {
				$paramsAsHash = $this->params;
				if(null == $paramsAsHash) throw new HException('null iterable');
				$»it = $paramsAsHash->keys();
				while($»it->hasNext()) {
					$k = $»it->next();
					$v = $paramsAsHash->get($k);
					$k = strtolower($k);
					if($fields->exists($k)) {
						$field = $fields->get($k);
						$this->{$field} = $v;
						unset($field);
					}
					unset($v);
				}
			}
		}
		$GLOBALS['%s']->pop();
	}
	public function createChildComponents() {
		$GLOBALS['%s']->push("haquery.server.HaqComponent::createChildComponents");
		$»spos = $GLOBALS['%s']->length;
		if($this->doc !== null) {
			$this->createChildComponents_inner($this->doc);
		}
		$GLOBALS['%s']->pop();
	}
	public function createChildComponents_inner($baseNode) {
		$GLOBALS['%s']->push("haquery.server.HaqComponent::createChildComponents_inner");
		$»spos = $GLOBALS['%s']->length;
		$i = 0;
		while($i < count($baseNode->children)) {
			$node = $baseNode->children[$i];
			haquery_base_HaQuery::assert($node->name !== "haq:placeholder", null, _hx_anonymous(array("fileName" => "HaqComponent.hx", "lineNumber" => 101, "className" => "haquery.server.HaqComponent", "methodName" => "createChildComponents_inner")));
			haquery_base_HaQuery::assert($node->name !== "haq:content", null, _hx_anonymous(array("fileName" => "HaqComponent.hx", "lineNumber" => 102, "className" => "haquery.server.HaqComponent", "methodName" => "createChildComponents_inner")));
			if(StringTools::startsWith($node->name, "haq:")) {
				$node->component = $this->manager->createComponent($this, $node->name, $node->getAttribute("id"), php_Lib::hashOfAssociativeArray($node->getAttributesAssoc()), $node->innerHTML);
			} else {
				$this->createChildComponents_inner($node);
			}
			$i++;
			unset($node);
		}
		$GLOBALS['%s']->pop();
	}
	public function prepareDocToRender($baseNode) {
		$GLOBALS['%s']->push("haquery.server.HaqComponent::prepareDocToRender");
		$»spos = $GLOBALS['%s']->length;
		$i = 0;
		while($i < count($baseNode->children)) {
			$node = $baseNode->children[$i];
			if(StringTools::startsWith($node->name, "haq:")) {
				if($node->component !== null) {
					if($node->component->visible) {
						$text = rtrim($node->component->render(), null);
						$prev = $node->getPrevSiblingNode();
						if($prev instanceof HaqXmlNodeText) {
							$re = new haquery_EReg("(?:^|\x0A)([ ]+)\$", "s");
							if($re->match(_hx_deref(($prev))->text)) {
								$text = str_replace("\x0A", "\x0A" . $re->matched(1), $text);
							}
							unset($re);
						}
						$node->parent->replaceChild($node, new HaqXmlNodeText($text));
						unset($text,$prev);
					} else {
						$node->remove();
					}
				}
			} else {
				$this->prepareDocToRender($node);
				$nodeID = $node->getAttribute("id");
				if($nodeID !== null && $nodeID !== "") {
					$node->setAttribute("id", $this->prefixID . $nodeID);
				}
				if($node->name === "label") {
					$nodeFor = $node->getAttribute("for");
					if($nodeFor !== null && $nodeFor !== "") {
						$node->setAttribute("for", $this->prefixID . $nodeFor);
					}
					unset($nodeFor);
				}
				unset($nodeID);
			}
			$i++;
			unset($node);
		}
		$GLOBALS['%s']->pop();
	}
	public function render() {
		$GLOBALS['%s']->push("haquery.server.HaqComponent::render");
		$»spos = $GLOBALS['%s']->length;
		if(haquery_base_HaQuery::$config->isTraceComponent) {
			haxe_Log::trace("render " . $this->fullID, _hx_anonymous(array("fileName" => "HaqComponent.hx", "lineNumber" => 170, "className" => "haquery.server.HaqComponent", "methodName" => "render")));
		}
		$this->prepareDocToRender($this->doc);
		$r = rtrim($this->doc->toString(), "\x0D\x0A");
		{
			$GLOBALS['%s']->pop();
			return $r;
		}
		$GLOBALS['%s']->pop();
	}
	public function q($query) {
		$GLOBALS['%s']->push("haquery.server.HaqComponent::q");
		$»spos = $GLOBALS['%s']->length;
		if($query === null) {
			$»tmp = new haquery_server_HaqQuery($this->prefixID, "", null);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		if(Type::getClassName(Type::getClass($query)) === "HaqQuery") {
			$GLOBALS['%s']->pop();
			return $query;
		}
		if(Type::getClassName(Type::getClass($query)) !== "String") {
			throw new HException("HaqComponent.q() error - 'query' parameter must be a string or HaqQuery.");
		}
		$nodes = $this->doc->find($query);
		{
			$»tmp = new haquery_server_HaqQuery($this->prefixID, $query, $nodes);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function callClientMethod($method, $params) {
		$GLOBALS['%s']->push("haquery.server.HaqComponent::callClientMethod");
		$»spos = $GLOBALS['%s']->length;
		$funcName = haquery_server_HaqComponent_0($this, $method, $params);
		haquery_server_HaqInternals::addAjaxAnswer(haquery_base_HaqTools::getCallClientFunctionString($funcName, $params) . ";");
		$GLOBALS['%s']->pop();
	}
	public function callElemEventHandler($elemID, $eventName) {
		$GLOBALS['%s']->push("haquery.server.HaqComponent::callElemEventHandler");
		$»spos = $GLOBALS['%s']->length;
		$handler = $elemID . "_" . $eventName;
		Reflect::callMethod($this, $handler, new _hx_array(array($this)));
		$GLOBALS['%s']->pop();
	}
	public function getSupportPath() {
		$GLOBALS['%s']->push("haquery.server.HaqComponent::getSupportPath");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $this->manager->getSupportPath($this->tag);
			$GLOBALS['%s']->pop();
			return $»tmp;
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
	function __toString() { return 'haquery.server.HaqComponent'; }
}
function haquery_server_HaqComponent_0(&$»this, &$method, &$params) {
	$»spos = $GLOBALS['%s']->length;
	if(strlen($»this->fullID) !== 0) {
		return "haquery.client.HaqSystem.page.findComponent('" . $»this->fullID . "')." . $method;
	} else {
		return "haquery.client.HaqSystem.page." . $method;
	}
}
