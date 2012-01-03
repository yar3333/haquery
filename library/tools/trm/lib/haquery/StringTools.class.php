<?php

class haquery_StringTools {
	public function __construct(){}
	static function urlEncode($s) {
		$GLOBALS['%s']->push("haquery.StringTools::urlEncode");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = rawurlencode($s);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function urlDecode($s) {
		$GLOBALS['%s']->push("haquery.StringTools::urlDecode");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = urldecode($s);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function htmlEscape($s) {
		$GLOBALS['%s']->push("haquery.StringTools::htmlEscape");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = StringTools::htmlEscape($s);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function htmlUnescape($s) {
		$GLOBALS['%s']->push("haquery.StringTools::htmlUnescape");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = htmlspecialchars_decode($s);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function startsWith($s, $start) {
		$GLOBALS['%s']->push("haquery.StringTools::startsWith");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = StringTools::startsWith($s, $start);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function endsWith($s, $end) {
		$GLOBALS['%s']->push("haquery.StringTools::endsWith");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = StringTools::endsWith($s, $end);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function isSpace($s, $pos) {
		$GLOBALS['%s']->push("haquery.StringTools::isSpace");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = StringTools::isSpace($s, $pos);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function ltrim($s, $chars) {
		$GLOBALS['%s']->push("haquery.StringTools::ltrim");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = ltrim($s, $chars);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function rtrim($s, $chars) {
		$GLOBALS['%s']->push("haquery.StringTools::rtrim");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = rtrim($s, $chars);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function trim($s, $chars) {
		$GLOBALS['%s']->push("haquery.StringTools::trim");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = trim($s, $chars);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function rpad($s, $c, $l) {
		$GLOBALS['%s']->push("haquery.StringTools::rpad");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = str_pad($s, $l, $c, STR_PAD_RIGHT);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function lpad($s, $c, $l) {
		$GLOBALS['%s']->push("haquery.StringTools::lpad");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = str_pad($s, $l, $c, STR_PAD_LEFT);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function replace($s, $sub, $by) {
		$GLOBALS['%s']->push("haquery.StringTools::replace");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = str_replace($sub, $by, $s);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function hex($n, $digits) {
		$GLOBALS['%s']->push("haquery.StringTools::hex");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = StringTools::hex($n, $digits);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function fastCodeAt($s, $index) {
		$GLOBALS['%s']->push("haquery.StringTools::fastCodeAt");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = ord(substr($s,$index,1));
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function isEOF($c) {
		$GLOBALS['%s']->push("haquery.StringTools::isEOF");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = ($c === 0);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function unescape($s) {
		$GLOBALS['%s']->push("haquery.StringTools::unescape");
		$»spos = $GLOBALS['%s']->length;
		
			$text = explode('%u', $s);
			$r = '';
			for ($i = 0; $i < count($text); $i++)
			{
				$r .= pack('H*', $text[$i]);
			}
			$r = mb_convert_encoding($r, 'UTF-8', 'UTF-16');
		;
		{
			$»tmp = $r;
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function escape($s) {
		$GLOBALS['%s']->push("haquery.StringTools::escape");
		$»spos = $GLOBALS['%s']->length;
		
			$text = mb_convert_encoding($s, 'UTF-16', 'UTF-8');
			$r = '';
			for ($i = 0; $i < mb_strlen($text, 'UTF-16'); $i++)
			{
				$r .= '%u'.bin2hex(mb_substr($text, $i, 1, 'UTF-16'));
			}
		;
		{
			$»tmp = $r;
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function toUpperCaseNational($s) {
		$GLOBALS['%s']->push("haquery.StringTools::toUpperCaseNational");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = mb_strtoupper($s, "UTF-8");
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function toLowerCaseNational($s) {
		$GLOBALS['%s']->push("haquery.StringTools::toLowerCaseNational");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = mb_strtolower($s, "UTF-8");
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function stripTags($s) {
		$GLOBALS['%s']->push("haquery.StringTools::stripTags");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = strip_tags($s);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function format($template, $value) {
		$GLOBALS['%s']->push("haquery.StringTools::format");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = sprintf($template, $value);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function jsonEncode($x) {
		$GLOBALS['%s']->push("haquery.StringTools::jsonEncode");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = json_encode($x);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function jsonDecode($s) {
		$GLOBALS['%s']->push("haquery.StringTools::jsonDecode");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = json_decode($s);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function hexdec($s) {
		$GLOBALS['%s']->push("haquery.StringTools::hexdec");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = hexdec($s);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function addcslashes($s) {
		$GLOBALS['%s']->push("haquery.StringTools::addcslashes");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = addcslashes($s, "'\"\x09\x0D\x0A\\");
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'haquery.StringTools'; }
}
