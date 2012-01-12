<?php

class haquery_server_HaqComponent extends haquery_base_HaqComponent {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		parent::__construct();
		$this->visible = true;
	}}
	public $manager;
	public $parentNode;
	public $doc;
	public $visible;
	public function construct($manager, $parent, $tag, $id, $doc, $params, $parentNode) {
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
	}
	public function getFieldsToLoadParams() {
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
		return $r;
	}
	public function loadParamsToObjectFields($params, $fields) {
		if($params !== null) {
			if(null == $params) throw new HException('null iterable');
			$»it = $params->keys();
			while($»it->hasNext()) {
				$k = $»it->next();
				$v = $params->get($k);
				$k = strtolower($k);
				if($fields->exists($k)) {
					$field = $fields->get($k);
					$»t = (Type::typeof(Reflect::field($this, $field)));
					switch($»t->index) {
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
	}
	public function createChildComponents() {
		if($this->doc !== null) {
			$this->createChildComponents_inner($this->doc);
		}
	}
	public function createChildComponents_inner($baseNode) {
		$i = 0;
		while($i < count($baseNode->children)) {
			$node = $baseNode->children[$i];
			null;
			null;
			$this->createChildComponents_inner($node);
			if(StringTools::startsWith($node->name, "haq:")) {
				$node->component = $this->manager->createComponent($this, $node->name, $node->getAttribute("id"), php_Lib::hashOfAssociativeArray($node->getAttributesAssoc()), $node);
			}
			$i++;
			unset($node);
		}
	}
	public function prepareDocToRender($baseNode) {
		$i = 0;
		while($i < count($baseNode->children)) {
			$node = $baseNode->children[$i];
			if(StringTools::startsWith($node->name, "haq:")) {
				if($node->component === null) {
					haxe_Log::trace("Component is null: " . $node->name, _hx_anonymous(array("fileName" => "HaqComponent.hx", "lineNumber" => 126, "className" => "haquery.server.HaqComponent", "methodName" => "prepareDocToRender")));
					null;
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
	}
	public function render() {
		if(haquery_server_Lib::$config->isTraceComponent) {
			haxe_Log::trace("render " . $this->fullID, _hx_anonymous(array("fileName" => "HaqComponent.hx", "lineNumber" => 172, "className" => "haquery.server.HaqComponent", "methodName" => "render")));
		}
		$this->prepareDocToRender($this->doc);
		$r = trim($this->doc->toString(), "\x0D\x0A");
		return $r;
	}
	public function q($query) {
		if($query === null) {
			return new haquery_server_HaqQuery($this->prefixID, "", null);
		}
		if(Type::getClass($query) == _hx_qtype("haquery.server.HaqQuery")) {
			return $query;
		}
		if($query instanceof HaqXmlNodeElement) {
			null;
			return new haquery_server_HaqQuery($this->prefixID, "", php_Lib::toPhpArray(new _hx_array(array($query))));
		}
		if(Type::getClassName(Type::getClass($query)) !== "String") {
			throw new HException("HaqComponent.q() error - 'query' parameter must be a string or HaqQuery.");
		}
		$nodes = $this->doc->find($query);
		return new haquery_server_HaqQuery($this->prefixID, $query, $nodes);
	}
	public function callClientMethod($method, $params) {
		null;
		$funcName = haquery_server_HaqComponent_0($this, $method, $params);
		haquery_server_HaqInternals::addAjaxResponse(haquery_base_HaqTools::getCallClientFunctionString($funcName, $params) . ";");
	}
	public function callElemEventHandler($elemID, $eventName) {
		$handler = $elemID . "_" . $eventName;
		Reflect::callMethod($this, $handler, new _hx_array(array($this)));
	}
	public function getSupportPath() {
		return $this->manager->getSupportPath($this->tag);
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
	if(strlen($»this->fullID) !== 0) {
		return "haquery.client.HaqSystem.page.findComponent('" . $»this->fullID . "')." . $method;
	} else {
		return "haquery.client.HaqSystem.page." . $method;
	}
}
