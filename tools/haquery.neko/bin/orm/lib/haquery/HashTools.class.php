<?php

class haquery_HashTools {
	public function __construct(){}
	static function add($dest, $src, $overwrite) {
		$GLOBALS['%s']->push("haquery.HashTools::add");
		$»spos = $GLOBALS['%s']->length;
		if($overwrite === null) {
			$overwrite = true;
		}
		if($overwrite) {
			if(null == $src) throw new HException('null iterable');
			$»it = $src->keys();
			while($»it->hasNext()) {
				$key = $»it->next();
				$dest->set($key, $src->get($key));
			}
		} else {
			if(null == $src) throw new HException('null iterable');
			$»it = $src->keys();
			while($»it->hasNext()) {
				$key = $»it->next();
				if(!$dest->exists($key)) {
					$dest->set($key, $src->get($key));
				}
			}
		}
		$GLOBALS['%s']->pop();
	}
	static function values($h) {
		$GLOBALS['%s']->push("haquery.HashTools::values");
		$»spos = $GLOBALS['%s']->length;
		$r = new _hx_array(array());
		if(null == $h) throw new HException('null iterable');
		$»it = $h->keys();
		while($»it->hasNext()) {
			$key = $»it->next();
			$r->push($h->get($key));
		}
		{
			$GLOBALS['%s']->pop();
			return $r;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'haquery.HashTools'; }
}
