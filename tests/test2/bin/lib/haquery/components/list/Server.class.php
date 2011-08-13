<?php

class haquery_components_list_Server extends haquery_server_HaqComponent {
	public function __construct() { if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("haquery.components.list.Server::new");
		$製pos = $GLOBALS['%s']->length;
		parent::__construct();
		$GLOBALS['%s']->pop();
	}}
	public function createChildComponents() {
		$GLOBALS['%s']->push("haquery.components.list.Server::createChildComponents");
		$製pos = $GLOBALS['%s']->length;
		if(haquery_base_HaQuery::$isPostback) {
			$length = Std::parseInt($this->q("#length")->val(null));
			haxe_Log::trace("length = " . $length, _hx_anonymous(array("fileName" => "Server.hx", "lineNumber" => 21, "className" => "haquery.components.list.Server", "methodName" => "createChildComponents")));
			{
				$_g = 0;
				while($_g < $length) {
					$i = $_g++;
					haxe_Log::trace("createComponent haq:listitem " . Std::string($i), _hx_anonymous(array("fileName" => "Server.hx", "lineNumber" => 24, "className" => "haquery.components.list.Server", "methodName" => "createChildComponents")));
					$this->manager->createComponent($this, "haq:listitem", Std::string($i), null, $this->innerHTML);
					unset($i);
				}
			}
		}
		$GLOBALS['%s']->pop();
	}
	public function bind($params) {
		$GLOBALS['%s']->push("haquery.components.list.Server::bind");
		$製pos = $GLOBALS['%s']->length;
		haquery_base_HaQuery::assert(!haquery_base_HaQuery::$isPostback, "Call bind on postback is not allowed.", _hx_anonymous(array("fileName" => "Server.hx", "lineNumber" => 32, "className" => "haquery.components.list.Server", "methodName" => "bind")));
		{
			$_g1 = 0; $_g = $params->length;
			while($_g1 < $_g) {
				$i = $_g1++;
				$p = new Hash();
				$p->set("seralizedParams", php_Lib::serialize($params[$i]));
				$this->manager->createComponent($this, "haq:listitem", Std::string($i), $p, $this->innerHTML);
				unset($p,$i);
			}
		}
		$this->q("#length")->val(Std::string($params->length));
		$GLOBALS['%s']->pop();
	}
	public function render() {
		$GLOBALS['%s']->push("haquery.components.list.Server::render");
		$製pos = $GLOBALS['%s']->length;
		$r = "";
		if(null == $this->components) throw new HException('null iterable');
		$蜴t = $this->components->iterator();
		while($蜴t->hasNext()) {
			$component = $蜴t->next();
			$r .= trim($component->render(), null) . "\x0A";
		}
		{
			$裨mp = parent::render() . "\x0A" . $r;
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'haquery.components.list.Server'; }
}
