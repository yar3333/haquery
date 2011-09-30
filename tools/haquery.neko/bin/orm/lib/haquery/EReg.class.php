<?php

class haquery_EReg extends EReg {
	public function __construct($r, $opt) { if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("haquery.EReg::new");
		$»spos = $GLOBALS['%s']->length;
		parent::__construct($r,$opt);
		$GLOBALS['%s']->pop();
	}}
	public function ensureCharset() {
		$GLOBALS['%s']->push("haquery.EReg::ensureCharset");
		$»spos = $GLOBALS['%s']->length;
		mb_regex_encoding("UTF-8");
		$GLOBALS['%s']->pop();
	}
	public function splitNational($s) {
		$GLOBALS['%s']->push("haquery.EReg::splitNational");
		$»spos = $GLOBALS['%s']->length;
		mb_regex_encoding("UTF-8");
		{
			$»tmp = new _hx_array(mb_split($this->pattern, $s, $this->hglobal ? -1 : 2));
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'haquery.EReg'; }
}
