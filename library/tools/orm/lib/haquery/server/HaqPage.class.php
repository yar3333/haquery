<?php

class haquery_server_HaqPage extends haquery_server_HaqComponent {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		parent::__construct();
		$this->contentType = "text/html; charset=utf-8";
	}}
	public $contentType;
	public $pageID;
	public function insertStyles($links) {
		$text = Lambda::map($links, array(new _hx_lambda(array(&$links), "haquery_server_HaqPage_0"), 'execute'))->join("\x0A        ");
		$heads = new _hx_array($this->doc->find(">html>head"));
		if($heads->length > 0) {
			$head = $heads[0];
			$child = null;
			$children = new _hx_array($head->children);
			if($children->length > 0) {
				$child = $head->children[0];
				while($child !== null && $child->name !== "link" && ($child->getAttribute("rel") !== "stylesheet" || $child->getAttribute("type") !== "text/css")) {
					$child = $child->getNextSiblingElement();
				}
			}
			$head->addChild(new HaqXmlNodeText($text . "\x0A        "), $child);
		} else {
			$this->doc->addChild(new HaqXmlNodeText($text . "\x0A"), null);
		}
	}
	public function insertScripts($links) {
		$text = Lambda::map($links, array(new _hx_lambda(array(&$links), "haquery_server_HaqPage_1"), 'execute'))->join("\x0A        ");
		$heads = new _hx_array($this->doc->find(">html>head"));
		if($heads->length > 0) {
			$head = $heads[0];
			$child = null;
			$children = new _hx_array($head->children);
			if($children->length > 0) {
				$child = $head->children[0];
				while($child !== null && $child->name !== "script") {
					$child = $child->getNextSiblingElement();
				}
			}
			$head->addChild(new HaqXmlNodeText("    " . $text . "\x0A    "), $child);
		} else {
			$this->doc->addChild(new HaqXmlNodeText($text . "\x0A"), null);
		}
	}
	public function insertInitInnerBlock($text) {
		$bodyes = new _hx_array($this->doc->find(">html>body"));
		if($bodyes->length > 0) {
			$body = $bodyes[0];
			$body->addChild(new HaqXmlNodeText("\x0A        " . str_replace("\x0A", "\x0A        ", $text) . "\x0A    "), null);
		} else {
			$this->doc->addChild(new HaqXmlNodeText("\x0A" . $text . "\x0A"), null);
		}
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
	static function getScriptLink($path) {
		$url = "/" . $path . "?" . php_FileSystem::stat($path)->mtime->getTime() / 1000;
		return "<script src='" . $url . "'></script>";
	}
	static function getStyleLink($path) {
		$url = "/" . $path . "?" . php_FileSystem::stat($path)->mtime->getTime() / 1000;
		return "<link rel='stylesheet' type='text/css' href='" . $url . "' />";
	}
	function __toString() { return 'haquery.server.HaqPage'; }
}
function haquery_server_HaqPage_0(&$links, $path) {
	{
		return haquery_server_HaqPage::getStyleLink($path);
	}
}
function haquery_server_HaqPage_1(&$links, $path) {
	{
		return haquery_server_HaqPage::getScriptLink($path);
	}
}
