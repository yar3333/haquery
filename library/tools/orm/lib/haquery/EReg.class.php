<?php

class haquery_EReg extends EReg {
	public function __construct($r, $opt) { if(!php_Boot::$skip_constructor) {
		parent::__construct($r,$opt);
	}}
	public function ensureCharset() {
		mb_regex_encoding("UTF-8");
	}
	public function splitNational($s) {
		mb_regex_encoding("UTF-8");
		return new _hx_array(mb_split($this->pattern, $s, $this->hglobal ? -1 : 2));
	}
	function __toString() { return 'haquery.EReg'; }
}
