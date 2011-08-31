<?php

class haquery_server_HaqPage extends haquery_server_HaqComponent {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("haquery.server.HaqPage::new");
		$»spos = $GLOBALS['%s']->length;
		parent::__construct();
		$this->contentType = "text/html; charset=utf-8";
		$GLOBALS['%s']->pop();
	}}
	public $contentType;
	public function insertStyles($links) {
		$GLOBALS['%s']->push("haquery.server.HaqPage::insertStyles");
		$»spos = $GLOBALS['%s']->length;
		$text = Lambda::map($links, array(new _hx_lambda(array(&$links), "haquery_server_HaqPage_0"), 'execute'))->join("\x0A        ");
		$heads = new _hx_array($this->doc->find(">html>head"));
		if($heads->length === 0) {
			throw new HException("HaqPage.insertStyles(): head tag not found.");
		}
		$head = $heads[0];
		$child = $head->children[0];
		while($child !== null && $child->name !== "link" && ($child->getAttribute("rel") !== "stylesheet" || $child->getAttribute("type") !== "text/css")) {
			$child = $child->getNextSiblingElement();
		}
		$head->addChild(new HaqXmlNodeText($text . "\x0A        "), $child);
		$GLOBALS['%s']->pop();
	}
	public function insertScripts($links) {
		$GLOBALS['%s']->push("haquery.server.HaqPage::insertScripts");
		$»spos = $GLOBALS['%s']->length;
		$text = Lambda::map($links, array(new _hx_lambda(array(&$links), "haquery_server_HaqPage_1"), 'execute'))->join("\x0A        ");
		$heads = new _hx_array($this->doc->find(">html>head"));
		if($heads->length === 0) {
			throw new HException("HaqPage.insertScripts(): head tag not found.");
		}
		$head = $heads[0];
		$child = $head->children[0];
		while($child !== null && $child->name !== "script") {
			$child = $child->getNextSiblingElement();
		}
		$head->addChild(new HaqXmlNodeText("    " . $text . "\x0A    "), $child);
		$GLOBALS['%s']->pop();
	}
	public function insertInitInnerBlock($text) {
		$GLOBALS['%s']->push("haquery.server.HaqPage::insertInitInnerBlock");
		$»spos = $GLOBALS['%s']->length;
		$bodyes = new _hx_array($this->doc->find(">html>body"));
		if($bodyes->length === 0) {
			throw new HException("HaqPage.insertInitInnerBlock(): body tag not found.");
		}
		$body = $bodyes[0];
		$body->addChild(new HaqXmlNodeText("\x0A        " . str_replace("\x0A", "\x0A        ", $text) . "\x0A    "), null);
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
	static function getScriptLink($path) {
		$GLOBALS['%s']->push("haquery.server.HaqPage::getScriptLink");
		$»spos = $GLOBALS['%s']->length;
		$url = "/" . $path . "?" . php_FileSystem::stat($path)->mtime->getTime() / 1000;
		{
			$»tmp = "<script src='" . $url . "'></script>";
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getStyleLink($path) {
		$GLOBALS['%s']->push("haquery.server.HaqPage::getStyleLink");
		$»spos = $GLOBALS['%s']->length;
		$url = "/" . $path . "?" . php_FileSystem::stat($path)->mtime->getTime() / 1000;
		{
			$»tmp = "<link rel='stylesheet' type='text/css' href='" . $url . "' />";
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'haquery.server.HaqPage'; }
}
function haquery_server_HaqPage_0(&$links, $path) {
	{
		$GLOBALS['%s']->push("haquery.server.HaqPage::insertStyles@24");
		$»spos2 = $GLOBALS['%s']->length;
		{
			$»tmp = haquery_server_HaqPage::getStyleLink($path);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
}
function haquery_server_HaqPage_1(&$links, $path) {
	{
		$GLOBALS['%s']->push("haquery.server.HaqPage::insertScripts@41");
		$»spos2 = $GLOBALS['%s']->length;
		{
			$»tmp = haquery_server_HaqPage::getScriptLink($path);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
}
