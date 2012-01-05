<?php

class haquery_server_HaqComponent extends haquery_base_HaqComponent {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("haquery.server.HaqComponent::new");
		$製pos = $GLOBALS['%s']->length;
		parent::__construct();
		$this->visible = true;
		$GLOBALS['%s']->pop();
	}}
	public $manager;
	public $parentNode;
	public $doc;
	public $visible;
	public function construct($manager, $parent, $tag, $id, $doc, $params, $parentNode) {
		$GLOBALS['%s']->push("haquery.server.HaqComponent::construct");
		$製pos = $GLOBALS['%s']->length;
		parent::commonConstruct($parent,$tag,$id);
		$this->manager = $manager;
		$this->doc = $doc;
		$this->parentNode = $parentNode;
		$this->loadParamsToObjectFields($params, $this->getFieldsToLoadParams());
		$this->createEvents();
		$this->createChildComponents();
		if(Reflect::isFunction(Reflect::field($this, "init"))) {
			Reflect::callMethod($this, Reflect::field($this, "init"), new _hx_array(array()));
		}
		$GLOBALS['%s']->pop();
	}
	public function getFieldsToLoadParams() {
		$GLOBALS['%s']->push("haquery.server.HaqComponent::getFieldsToLoadParams");
		$製pos = $GLOBALS['%s']->length;
		$restrictedFields = Reflect::fields(Type::createEmptyInstance(Type::resolveClass("haquery.server.HaqComponent")));
		$r = new Hash();
		{
			$_g = 0; $_g1 = Reflect::fields($this);
			while($_g < $_g1->length) {
				$field = $_g1[$_g];
				++$_g;
				if(!Reflect::isFunction(Reflect::field($this, $field)) && !Lambda::has($restrictedFields, $field, null) && !StringTools::startsWith($field, "event_")) {
					$r->set(strtolower($field), $field);
				}
				unset($field);
			}
		}
		{
			$GLOBALS['%s']->pop();
			return $r;
		}
		$GLOBALS['%s']->pop();
	}
	public function loadParamsToObjectFields($params, $fields) {
		$GLOBALS['%s']->push("haquery.server.HaqComponent::loadParamsToObjectFields");
		$製pos = $GLOBALS['%s']->length;
		if($params !== null) {
			if(null == $params) throw new HException('null iterable');
			$蜴t = $params->keys();
			while($蜴t->hasNext()) {
				$k = $蜴t->next();
				$v = $params->get($k);
				$k = strtolower($k);
				if($fields->exists($k)) {
					$field = $fields->get($k);
					$裨 = (Type::typeof(Reflect::field($this, $field)));
					switch($裨->index) {
					case 1:
					{
						$v = Std::parseInt($v);
					}break;
					case 2:
					{
						$v = Std::parseFloat($v);
					}break;
					case 3:
					{
						$v = haquery_base_HaqTools::bool($v);
					}break;
					default:{
					}break;
					}
					$this->{$field} = $v;
					unset($field);
				}
				unset($v);
			}
		}
		$GLOBALS['%s']->pop();
	}
	public function createChildComponents() {
		$GLOBALS['%s']->push("haquery.server.HaqComponent::createChildComponents");
		$製pos = $GLOBALS['%s']->length;
		if($this->doc !== null) {
			$this->createChildComponents_inner($this->doc);
		}
		$GLOBALS['%s']->pop();
	}
	public function createChildComponents_inner($baseNode) {
		$GLOBALS['%s']->push("haquery.server.HaqComponent::createChildComponents_inner");
		$製pos = $GLOBALS['%s']->length;
		$i = 0;
		while($i < count($baseNode->children)) {
			$node = $baseNode->children[$i];
			haquery_server_Lib::assert($node->name !== "haq:placeholder", null, _hx_anonymous(array("fileName" => "HaqComponent.hx", "lineNumber" => 103, "className" => "haquery.server.HaqComponent", "methodName" => "createChildComponents_inner")));
			haquery_server_Lib::assert($node->name !== "haq:content", null, _hx_anonymous(array("fileName" => "HaqComponent.hx", "lineNumber" => 104, "className" => "haquery.server.HaqComponent", "methodName" => "createChildComponents_inner")));
			$this->createChildComponents_inner($node);
			if(StringTools::startsWith($node->name, "haq:")) {
				$node->component = $this->manager->createComponent($this, $node->name, $node->getAttribute("id"), php_Lib::hashOfAssociativeArray($node->getAttributesAssoc()), $node);
			}
			$i++;
			unset($node);
		}
		$GLOBALS['%s']->pop();
	}
	public function prepareDocToRender($baseNode) {
		$GLOBALS['%s']->push("haquery.server.HaqComponent::prepareDocToRender");
		$製pos = $GLOBALS['%s']->length;
		$i = 0;
		while($i < count($baseNode->children)) {
			$node = $baseNode->children[$i];
			if(StringTools::startsWith($node->name, "haq:")) {
				if($node->component === null) {
					haxe_Log::trace("Component is null: " . $node->name, _hx_anonymous(array("fileName" => "HaqComponent.hx", "lineNumber" => 126, "className" => "haquery.server.HaqComponent", "methodName" => "prepareDocToRender")));
					haquery_server_Lib::assert(false, null, _hx_anonymous(array("fileName" => "HaqComponent.hx", "lineNumber" => 127, "className" => "haquery.server.HaqComponent", "methodName" => "prepareDocToRender")));
				}
				if($node->component->visible) {
					$this->prepareDocToRender($node);
					$text = trim($node->component->render(), null);
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
					$i--;
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
		$製pos = $GLOBALS['%s']->length;
		if(haquery_server_Lib::$config->isTraceComponent) {
			haxe_Log::trace("render " . $this->fullID, _hx_anonymous(array("fileName" => "HaqComponent.hx", "lineNumber" => 172, "className" => "haquery.server.HaqComponent", "methodName" => "render")));
		}
		$this->prepareDocToRender($this->doc);
		$r = trim($this->doc->toString(), "\x0D\x0A");
		{
			$GLOBALS['%s']->pop();
			return $r;
		}
		$GLOBALS['%s']->pop();
	}
	public function q($query) {
		$GLOBALS['%s']->push("haquery.server.HaqComponent::q");
		$製pos = $GLOBALS['%s']->length;
		if($query === null) {
			$裨mp = new haquery_server_HaqQuery($this->prefixID, "", null);
			$GLOBALS['%s']->pop();
			return $裨mp;
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
			$裨mp = new haquery_server_HaqQuery($this->prefixID, $query, $nodes);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	public function callClientMethod($method, $params) {
		$GLOBALS['%s']->push("haquery.server.HaqComponent::callClientMethod");
		$製pos = $GLOBALS['%s']->length;
		haquery_server_Lib::assert(haquery_server_Lib::$isPostback, "HaqComponent.callClientMethod() allowed on the postback only.", _hx_anonymous(array("fileName" => "HaqComponent.hx", "lineNumber" => 197, "className" => "haquery.server.HaqComponent", "methodName" => "callClientMethod")));
		$funcName = haquery_server_HaqComponent_0($this, $method, $params);
		haquery_server_HaqInternals::addAjaxResponse(haquery_base_HaqTools::getCallClientFunctionString($funcName, $params) . ";");
		$GLOBALS['%s']->pop();
	}
	public function callElemEventHandler($elemID, $eventName) {
		$GLOBALS['%s']->push("haquery.server.HaqComponent::callElemEventHandler");
		$製pos = $GLOBALS['%s']->length;
		$handler = $elemID . "_" . $eventName;
		Reflect::callMethod($this, $handler, new _hx_array(array($this)));
		$GLOBALS['%s']->pop();
	}
	public function getSupportPath() {
		$GLOBALS['%s']->push("haquery.server.HaqComponent::getSupportPath");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = $this->manager->getSupportPath($this->tag);
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
	function __toString() { return 'haquery.server.HaqComponent'; }
}
function haquery_server_HaqComponent_0(&$裨his, &$method, &$params) {
	$製pos = $GLOBALS['%s']->length;
	if(strlen($裨his->fullID) !== 0) {
		return "haquery.client.HaqSystem.page.findComponent('" . $裨his->fullID . "')." . $method;
	} else {
		return "haquery.client.HaqSystem.page." . $method;
	}
}
