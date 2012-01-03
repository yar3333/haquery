<?php

class haquery_server_HaqConfig {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("haquery.server.HaqConfig::new");
		$�spos = $GLOBALS['%s']->length;
		$this->db = _hx_anonymous(array("type" => null, "host" => null, "user" => null, "pass" => null, "database" => null));
		$this->autoSessionStart = true;
		$this->autoDatabaseConnect = true;
		$this->sqlTraceLevel = 1;
		$this->isTraceComponent = false;
		$this->filterTracesByIP = "";
		$this->customData = new Hash();
		$this->componentsPackage = "haquery.components";
		$this->layout = null;
		$this->disablePageMetaData = false;
		$GLOBALS['%s']->pop();
	}}
	public $db;
	public $autoSessionStart;
	public $autoDatabaseConnect;
	public $sqlTraceLevel;
	public $isTraceComponent;
	public $filterTracesByIP;
	public $customData;
	public $componentsPackage;
	public $layout;
	public $disablePageMetaData;
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
	static function getComponentsConfig($basePath, $componentsPackage) {
		$GLOBALS['%s']->push("haquery.server.HaqConfig::getComponentsConfig");
		$�spos = $GLOBALS['%s']->length;
		$r = _hx_anonymous(array("extendsPackage" => (($componentsPackage !== "haquery.components") ? "haquery.components" : null)));
		$configFilePath = str_replace(".", "/", $componentsPackage) . "/config.xml";
		if(file_exists($basePath . $configFilePath)) {
			$text = php_io_File::getContent($basePath . $configFilePath);
			$xml = Xml::parse($text);
			if($xml->firstElement()->getNodeName() === "components") {
				if(null == $xml->firstElement()) throw new HException('null iterable');
				$�it = $xml->firstElement()->elements();
				while($�it->hasNext()) {
					$elem = $�it->next();
					if($elem->getNodeName() === "extends") {
						if($elem->exists("package")) {
							$r->extendsPackage = $elem->get("package");
						}
					}
				}
			}
		}
		{
			$GLOBALS['%s']->pop();
			return $r;
		}
		$GLOBALS['%s']->pop();
	}
	static function getComponentsFolders($basePath, $componentsPackage) {
		$GLOBALS['%s']->push("haquery.server.HaqConfig::getComponentsFolders");
		$�spos = $GLOBALS['%s']->length;
		if($basePath !== "") {
			$basePath = rtrim(str_replace("\\", "/", $basePath), "/") . "/";
		}
		$r = new _hx_array(array());
		if($componentsPackage !== null && $componentsPackage !== "") {
			$path = str_replace(".", "/", $componentsPackage);
			if(!is_dir($basePath . $path)) {
				throw new HException("Components directory '" . $path . "' do not exists.");
			}
			$r->unshift($path . "/");
			$config = haquery_server_HaqConfig::getComponentsConfig($basePath, $componentsPackage);
			{
				$_g = 0; $_g1 = haquery_server_HaqConfig::getComponentsFolders($basePath, $config->extendsPackage);
				while($_g < $_g1->length) {
					$path1 = $_g1[$_g];
					++$_g;
					$r->unshift($path1);
					unset($path1);
				}
			}
		}
		{
			$GLOBALS['%s']->pop();
			return $r;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'haquery.server.HaqConfig'; }
}
