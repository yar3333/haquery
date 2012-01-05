<?php

class haquery_server_Web {
	public function __construct(){}
	static function getParams() {
		$GLOBALS['%s']->push("haquery.server.Web::getParams");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = php_Web::getParams();
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getParamValues($param) {
		$GLOBALS['%s']->push("haquery.server.Web::getParamValues");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = php_Web::getParamValues($param);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getHostName() {
		$GLOBALS['%s']->push("haquery.server.Web::getHostName");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $_SERVER['SERVER_NAME'];
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getClientIP() {
		$GLOBALS['%s']->push("haquery.server.Web::getClientIP");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $_SERVER['REMOTE_ADDR'];
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getURI() {
		$GLOBALS['%s']->push("haquery.server.Web::getURI");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = php_Web::getURI();
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function redirect($url) {
		$GLOBALS['%s']->push("haquery.server.Web::redirect");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = haquery_server_Lib::redirect($url);
			$GLOBALS['%s']->pop();
			$»tmp;
			return;
		}
		$GLOBALS['%s']->pop();
	}
	static function setHeader($h, $v) {
		$GLOBALS['%s']->push("haquery.server.Web::setHeader");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = header($h . ": " . $v);
			$GLOBALS['%s']->pop();
			$»tmp;
			return;
		}
		$GLOBALS['%s']->pop();
	}
	static function setReturnCode($r) {
		$GLOBALS['%s']->push("haquery.server.Web::setReturnCode");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = php_Web::setReturnCode($r);
			$GLOBALS['%s']->pop();
			$»tmp;
			return;
		}
		$GLOBALS['%s']->pop();
	}
	static function getClientHeader($k) {
		$GLOBALS['%s']->push("haquery.server.Web::getClientHeader");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = php_Web::getClientHeader($k);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getClientHeaders() {
		$GLOBALS['%s']->push("haquery.server.Web::getClientHeaders");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = php_Web::getClientHeaders();
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getParamsString() {
		$GLOBALS['%s']->push("haquery.server.Web::getParamsString");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = php_Web::getParamsString();
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getPostData() {
		$GLOBALS['%s']->push("haquery.server.Web::getPostData");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = php_Web::getPostData();
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getAuthorization() {
		$GLOBALS['%s']->push("haquery.server.Web::getAuthorization");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = php_Web::getAuthorization();
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getCwd() {
		$GLOBALS['%s']->push("haquery.server.Web::getCwd");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = dirname($_SERVER["SCRIPT_FILENAME"]) . "/";
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getMultipart($maxSize) {
		$GLOBALS['%s']->push("haquery.server.Web::getMultipart");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = php_Web::getMultipart($maxSize);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function parseMultipart($onPart, $onData) {
		$GLOBALS['%s']->push("haquery.server.Web::parseMultipart");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = php_Web::parseMultipart($onPart, $onData);
			$GLOBALS['%s']->pop();
			$»tmp;
			return;
		}
		$GLOBALS['%s']->pop();
	}
	static function flush() {
		$GLOBALS['%s']->push("haquery.server.Web::flush");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = flush();
			$GLOBALS['%s']->pop();
			$»tmp;
			return;
		}
		$GLOBALS['%s']->pop();
	}
	static function getMethod() {
		$GLOBALS['%s']->push("haquery.server.Web::getMethod");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = php_Web::getMethod();
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static $isModNeko;
	static function isModNeko_getter() {
		$GLOBALS['%s']->push("haquery.server.Web::isModNeko_getter");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = php_Web::$isModNeko;
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getDocumentRoot() {
		$GLOBALS['%s']->push("haquery.server.Web::getDocumentRoot");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $_SERVER['DOCUMENT_ROOT'];
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getHttpHost() {
		$GLOBALS['%s']->push("haquery.server.Web::getHttpHost");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $_SERVER['HTTP_HOST'];
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getFiles() {
		$GLOBALS['%s']->push("haquery.server.Web::getFiles");
		$»spos = $GLOBALS['%s']->length;
		$files = php_Lib::hashOfAssociativeArray($_FILES);
		$r = new Hash();
		if(null == $files) throw new HException('null iterable');
		$»it = $files->keys();
		while($»it->hasNext()) {
			$id = $»it->next();
			$file = $files->get($id);
			$r->set($id, new haquery_server_UploadedFile($file["name"], $file["type"], $file["tmp_name"], Type::createEnumIndex(_hx_qtype("haquery.server.UploadError"), $file["error"], null), $file["size"]));
			unset($file);
		}
		{
			$GLOBALS['%s']->pop();
			return $r;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'haquery.server.Web'; }
}
