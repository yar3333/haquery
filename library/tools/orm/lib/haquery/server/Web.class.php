<?php

class haquery_server_Web {
	public function __construct(){}
	static function getParams() {
		return php_Web::getParams();
	}
	static function getParamValues($param) {
		return php_Web::getParamValues($param);
	}
	static function getHostName() {
		return $_SERVER['SERVER_NAME'];
	}
	static function getClientIP() {
		return $_SERVER['REMOTE_ADDR'];
	}
	static function getURI() {
		return php_Web::getURI();
	}
	static function redirect($url) {
		haquery_server_Lib::redirect($url);
		return;
	}
	static function setHeader($h, $v) {
		header($h . ": " . $v);
		return;
	}
	static function setReturnCode($r) {
		php_Web::setReturnCode($r);
		return;
	}
	static function getClientHeader($k) {
		return php_Web::getClientHeader($k);
	}
	static function getClientHeaders() {
		return php_Web::getClientHeaders();
	}
	static function getParamsString() {
		return php_Web::getParamsString();
	}
	static function getPostData() {
		return php_Web::getPostData();
	}
	static function getAuthorization() {
		return php_Web::getAuthorization();
	}
	static function getCwd() {
		return dirname($_SERVER["SCRIPT_FILENAME"]) . "/";
	}
	static function getMultipart($maxSize) {
		return php_Web::getMultipart($maxSize);
	}
	static function parseMultipart($onPart, $onData) {
		php_Web::parseMultipart($onPart, $onData);
		return;
	}
	static function flush() {
		flush();
		return;
	}
	static function getMethod() {
		return php_Web::getMethod();
	}
	static $isModNeko;
	static function isModNeko_getter() {
		return php_Web::$isModNeko;
	}
	static function getDocumentRoot() {
		return $_SERVER['DOCUMENT_ROOT'];
	}
	static function getHttpHost() {
		return $_SERVER['HTTP_HOST'];
	}
	static function getFiles() {
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
		return $r;
	}
	function __toString() { return 'haquery.server.Web'; }
}
