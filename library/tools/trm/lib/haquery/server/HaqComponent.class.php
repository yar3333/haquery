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
	public $parentNode;
	public $doc;
	public $visible;
	public function construct($manager, $parent, $tag, $id, $doc, $params, $parentNode) {
		$GLOBALS['%s']->push("haquery.server.HaqComponent::construct");
		$»spos = $GLOBALS['%s']->length;
		parent::commonConstruct($parent,$tag,$id);
		$this->manager = $manager;
		$this->doc = $doc;
		$this->parentNode = $parentNode;
		if($params !== null) {
			$fields = $manager->getFieldsToLoadParams($this);
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
		$this->createEvents();
		$this->createChildComponents();
		if(Reflect::isFunction(Reflect::field($this, "init"))) {
			Reflect::callMethod($this, Reflect::field($this, "init"), new _hx_array(array()));
		}
		$GLOBALS['%s']->pop();
	}
	public function createChildComponents() {
		$GLOBALS['%s']->push("haquery.server.HaqComponent::createChildComponents");
		$»spos = $GLOBALS['%s']->length;
		if($this->doc !== null) {
			$this->manager->createChildComponents($this, $this->doc);
		}
		$GLOBALS['%s']->pop();
	}
	public function render() {
		$GLOBALS['%s']->push("haquery.server.HaqComponent::render");
		$»spos = $GLOBALS['%s']->length;
		if(haquery_server_Lib::$config->isTraceComponent) {
			haxe_Log::trace("render " . $this->fullID, _hx_anonymous(array("fileName" => "HaqComponent.hx", "lineNumber" => 81, "className" => "haquery.server.HaqComponent", "methodName" => "render")));
		}
		$this->manager->prepareDocToRender($this->prefixID, $this->doc);
		$r = trim($this->doc->toString(), "\x0D\x0A");
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
		if(Type::getClass($query) == _hx_qtype("haquery.server.HaqQuery")) {
			$GLOBALS['%s']->pop();
			return $query;
		}
		if($query instanceof HaqXmlNodeElement) {
			haquery_server_Lib::assert(!haquery_server_Lib::$isPostback, "Calling of the HaqComponent.q() with HaqXmlNodeElement parameter do not possible on the postback.", _hx_anonymous(array("fileName" => "HaqComponent.hx", "lineNumber" => 99, "className" => "haquery.server.HaqComponent", "methodName" => "q")));
			{
				$»tmp = new haquery_server_HaqQuery($this->prefixID, "", php_Lib::toPhpArray(new _hx_array(array($query))));
				$GLOBALS['%s']->pop();
				return $»tmp;
			}
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
		haquery_server_Lib::assert(haquery_server_Lib::$isPostback, "HaqComponent.callClientMethod() allowed on the postback only.", _hx_anonymous(array("fileName" => "HaqComponent.hx", "lineNumber" => 114, "className" => "haquery.server.HaqComponent", "methodName" => "callClientMethod")));
		$funcName = haquery_server_HaqComponent_0($this, $method, $params);
		haquery_server_HaqInternals::addAjaxResponse(haquery_base_HaqTools::getCallClientFunctionString($funcName, $params) . ";");
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
	public function registerScript($url) {
		$GLOBALS['%s']->push("haquery.server.HaqComponent::registerScript");
		$»spos = $GLOBALS['%s']->length;
		$this->manager->registerScript($this->tag, $url);
		$GLOBALS['%s']->pop();
	}
	public function registerStyle($url) {
		$GLOBALS['%s']->push("haquery.server.HaqComponent::registerStyle");
		$»spos = $GLOBALS['%s']->length;
		$this->manager->registerStyle($this->tag, $url);
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
