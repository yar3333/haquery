<?php

class php_io_Path {
	public function __construct($path) {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("php.io.Path::new");
		$»spos = $GLOBALS['%s']->length;
		$c1 = _hx_last_index_of($path, "/", null);
		$c2 = _hx_last_index_of($path, "\\", null);
		if($c1 < $c2) {
			$this->dir = _hx_substr($path, 0, $c2);
			$path = _hx_substr($path, $c2 + 1, null);
			$this->backslash = true;
		} else {
			if($c2 < $c1) {
				$this->dir = _hx_substr($path, 0, $c1);
				$path = _hx_substr($path, $c1 + 1, null);
			} else {
				$this->dir = null;
			}
		}
		$cp = _hx_last_index_of($path, ".", null);
		if($cp !== -1) {
			$this->ext = _hx_substr($path, $cp + 1, null);
			$this->file = _hx_substr($path, 0, $cp);
		} else {
			$this->ext = null;
			$this->file = $path;
		}
		$GLOBALS['%s']->pop();
	}}
	public $ext;
	public $dir;
	public $file;
	public $backslash;
	public function toString() {
		$GLOBALS['%s']->push("php.io.Path::toString");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = (php_io_Path_0($this)) . $this->file . (php_io_Path_1($this));
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
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
	static function withoutExtension($path) {
		$GLOBALS['%s']->push("php.io.Path::withoutExtension");
		$»spos = $GLOBALS['%s']->length;
		$s = new php_io_Path($path);
		$s->ext = null;
		{
			$»tmp = $s->toString();
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function withoutDirectory($path) {
		$GLOBALS['%s']->push("php.io.Path::withoutDirectory");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = basename($path);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function directory($path) {
		$GLOBALS['%s']->push("php.io.Path::directory");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = dirname($path);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function extension($path) {
		$GLOBALS['%s']->push("php.io.Path::extension");
		$»spos = $GLOBALS['%s']->length;
		$s = new php_io_Path($path);
		if($s->ext === null) {
			$GLOBALS['%s']->pop();
			return "";
		}
		{
			$»tmp = $s->ext;
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function withExtension($path, $ext) {
		$GLOBALS['%s']->push("php.io.Path::withExtension");
		$»spos = $GLOBALS['%s']->length;
		$s = new php_io_Path($path);
		$s->ext = $ext;
		{
			$»tmp = $s->toString();
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return $this->toString(); }
}
function php_io_Path_0(&$»this) {
	$»spos = $GLOBALS['%s']->length;
	if($»this->dir === null) {
		return "";
	} else {
		return $»this->dir . ((($»this->backslash) ? "\\" : "/"));
	}
}
function php_io_Path_1(&$»this) {
	$»spos = $GLOBALS['%s']->length;
	if($»this->ext === null) {
		return "";
	} else {
		return "." . $»this->ext;
	}
}
