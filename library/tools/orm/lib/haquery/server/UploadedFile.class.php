<?php

class haquery_server_UploadedFile {
	public function __construct($name, $type, $tmp_name, $error, $size) {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("haquery.server.UploadedFile::new");
		$»spos = $GLOBALS['%s']->length;
		$this->name = $name;
		$this->type = $type;
		$this->tmp_name = $tmp_name;
		$this->error = $error;
		$this->size = $size;
		$GLOBALS['%s']->pop();
	}}
	public $name;
	public $type;
	public $tmp_name;
	public $error;
	public $size;
	public function move($destFilePath) {
		$GLOBALS['%s']->push("haquery.server.UploadedFile::move");
		$»spos = $GLOBALS['%s']->length;
		move_uploaded_file($this->tmp_name, $destFilePath);
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
	function __toString() { return 'haquery.server.UploadedFile'; }
}
