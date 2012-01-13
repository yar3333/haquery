<?php

class haquery_base_HaqComponent {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("haquery.base.HaqComponent::new");
		$�spos = $GLOBALS['%s']->length;
		$this->components = new Hash();
		$this->nextAnonimID = 0;
		$�t = (Type::typeof($this));
		switch($�t->index) {
		case 6:
		$cls = $�t->params[0];
		{
			if(Lambda::has(Type::getInstanceFields($cls), "template", null)) {
				$className = Type::getClassName($cls);
				$lastPointPos = _hx_last_index_of($className, ".", null);
				if($lastPointPos > 0) {
					$templateClassName = _hx_substr($className, 0, $lastPointPos) . ".Template";
					$templateClass = Type::resolveClass($templateClassName);
					if($templateClass !== null) {
						$this->{"template"} = Type::createInstance($templateClass, new _hx_array(array($this)));
					}
				}
			}
		}break;
		default:{
		}break;
		}
		$GLOBALS['%s']->pop();
	}}
	public $id;
	public $parent;
	public $tag;
	public $fullID;
	public $prefixID;
	public $components;
	public $nextAnonimID;
	public function commonConstruct($parent, $tag, $id) {
		$GLOBALS['%s']->push("haquery.base.HaqComponent::commonConstruct");
		$�spos = $GLOBALS['%s']->length;
		if($id === null || $id === "") {
			$id = (($parent !== null) ? $parent->getNextAnonimID() : "");
		}
		$this->parent = $parent;
		$this->tag = $tag;
		$this->id = $id;
		$this->fullID = (haquery_base_HaqComponent_0($this, $id, $parent, $tag)) . $id;
		$this->prefixID = haquery_base_HaqComponent_1($this, $id, $parent, $tag);
		if($parent !== null) {
			haquery_server_Lib::assert(!$parent->components->exists($id), "Component with same id '" . $id . "' already exist.", _hx_anonymous(array("fileName" => "HaqComponent.hx", "lineNumber" => 85, "className" => "haquery.base.HaqComponent", "methodName" => "commonConstruct")));
			$parent->components->set($id, $this);
		}
		$GLOBALS['%s']->pop();
	}
	public function createEvents() {
		$GLOBALS['%s']->push("haquery.base.HaqComponent::createEvents");
		$�spos = $GLOBALS['%s']->length;
		if($this->parent !== null) {
			$_g = 0; $_g1 = Type::getInstanceFields(Type::getClass($this));
			while($_g < $_g1->length) {
				$field = $_g1[$_g];
				++$_g;
				if(StringTools::startsWith($field, "event_")) {
					$event = Reflect::field($this, $field);
					if($event === null) {
						$event = new haquery_base_HaqEvent($this, _hx_substr($field, strlen("event_"), null));
						$this->{$field} = $event;
					}
					$this->parent->connectEventHandlers($event);
					unset($event);
				}
				unset($field);
			}
		}
		$GLOBALS['%s']->pop();
	}
	public function connectEventHandlers($event) {
		$GLOBALS['%s']->push("haquery.base.HaqComponent::connectEventHandlers");
		$�spos = $GLOBALS['%s']->length;
		$handlerName = $event->component->id . "_" . $event->name;
		if(Reflect::isFunction(Reflect::field($this, $handlerName))) {
			$event->bind($this, Reflect::field($this, $handlerName));
		}
		$GLOBALS['%s']->pop();
	}
	public function forEachComponent($f, $isFromTopToBottom) {
		$GLOBALS['%s']->push("haquery.base.HaqComponent::forEachComponent");
		$�spos = $GLOBALS['%s']->length;
		if($isFromTopToBottom === null) {
			$isFromTopToBottom = true;
		}
		if($isFromTopToBottom && Reflect::isFunction(Reflect::field($this, $f))) {
			Reflect::callMethod($this, Reflect::field($this, $f), new _hx_array(array()));
		}
		if(null == $this->components) throw new HException('null iterable');
		$�it = $this->components->iterator();
		while($�it->hasNext()) {
			$component = $�it->next();
			$component->forEachComponent($f, $isFromTopToBottom);
		}
		if(!$isFromTopToBottom && Reflect::isFunction(Reflect::field($this, $f))) {
			Reflect::callMethod($this, Reflect::field($this, $f), new _hx_array(array()));
		}
		$GLOBALS['%s']->pop();
	}
	public function findComponent($fullID) {
		$GLOBALS['%s']->push("haquery.base.HaqComponent::findComponent");
		$�spos = $GLOBALS['%s']->length;
		if($fullID === "") {
			$�tmp = $this;
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$ids = _hx_explode("-", $fullID);
		$r = $this;
		{
			$_g = 0;
			while($_g < $ids->length) {
				$id = $ids[$_g];
				++$_g;
				if(!$r->components->exists($id)) {
					$GLOBALS['%s']->pop();
					return null;
				}
				$r = $r->components->get($id);
				unset($id);
			}
		}
		{
			$�tmp = $r;
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function getNextAnonimID() {
		$GLOBALS['%s']->push("haquery.base.HaqComponent::getNextAnonimID");
		$�spos = $GLOBALS['%s']->length;
		$this->nextAnonimID++;
		{
			$�tmp = "haqc_" . Std::string($this->nextAnonimID);
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
	function __toString() { return 'haquery.base.HaqComponent'; }
}
function haquery_base_HaqComponent_0(&$�this, &$id, &$parent, &$tag) {
	$�spos = $GLOBALS['%s']->length;
	if($parent !== null) {
		return $parent->prefixID;
	} else {
		return "";
	}
}
function haquery_base_HaqComponent_1(&$�this, &$id, &$parent, &$tag) {
	$�spos = $GLOBALS['%s']->length;
	if($�this->fullID !== "") {
		return $�this->fullID . "-";
	} else {
		return "";
	}
}
