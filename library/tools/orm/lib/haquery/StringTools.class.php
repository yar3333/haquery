<?php

class haquery_StringTools {
	public function __construct(){}
	static function urlEncode($s) {
		return rawurlencode($s);
	}
	static function urlDecode($s) {
		return urldecode($s);
	}
	static function htmlEscape($s) {
		return StringTools::htmlEscape($s);
	}
	static function htmlUnescape($s) {
		return htmlspecialchars_decode($s);
	}
	static function startsWith($s, $start) {
		return StringTools::startsWith($s, $start);
	}
	static function endsWith($s, $end) {
		return StringTools::endsWith($s, $end);
	}
	static function isSpace($s, $pos) {
		return StringTools::isSpace($s, $pos);
	}
	static function ltrim($s, $chars) {
		return ltrim($s, $chars);
	}
	static function rtrim($s, $chars) {
		return rtrim($s, $chars);
	}
	static function trim($s, $chars) {
		return trim($s, $chars);
	}
	static function rpad($s, $c, $l) {
		return str_pad($s, $l, $c, STR_PAD_RIGHT);
	}
	static function lpad($s, $c, $l) {
		return str_pad($s, $l, $c, STR_PAD_LEFT);
	}
	static function replace($s, $sub, $by) {
		return str_replace($sub, $by, $s);
	}
	static function hex($n, $digits) {
		return StringTools::hex($n, $digits);
	}
	static function fastCodeAt($s, $index) {
		return ord(substr($s,$index,1));
	}
	static function isEOF($c) {
		return ($c === 0);
	}
	static function unescape($s) {
		
			$text = explode('%u', $s);
			$r = '';
			for ($i = 0; $i < count($text); $i++)
			{
				$r .= pack('H*', $text[$i]);
			}
			$r = mb_convert_encoding($r, 'UTF-8', 'UTF-16');
		;
		return $r;
	}
	static function escape($s) {
		
			$text = mb_convert_encoding($s, 'UTF-16', 'UTF-8');
			$r = '';
			for ($i = 0; $i < mb_strlen($text, 'UTF-16'); $i++)
			{
				$r .= '%u'.bin2hex(mb_substr($text, $i, 1, 'UTF-16'));
			}
		;
		return $r;
	}
	static function toUpperCaseNational($s) {
		return mb_strtoupper($s, "UTF-8");
	}
	static function toLowerCaseNational($s) {
		return mb_strtolower($s, "UTF-8");
	}
	static function stripTags($s) {
		return strip_tags($s);
	}
	static function format($template, $value) {
		return sprintf($template, $value);
	}
	static function jsonEncode($x) {
		return json_encode($x);
	}
	static function jsonDecode($s) {
		return json_decode($s);
	}
	static function hexdec($s) {
		return hexdec($s);
	}
	static function addcslashes($s) {
		return addcslashes($s, "'\"\x09\x0D\x0A\\");
	}
	function __toString() { return 'haquery.StringTools'; }
}
