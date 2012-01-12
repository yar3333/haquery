<?php

class haquery_HashTools {
	public function __construct(){}
	static function add($dest, $src, $overwrite) {
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
	}
	static function values($h) {
		$r = new _hx_array(array());
		if(null == $h) throw new HException('null iterable');
		$»it = $h->keys();
		while($»it->hasNext()) {
			$key = $»it->next();
			$r->push($h->get($key));
		}
		return $r;
	}
	function __toString() { return 'haquery.HashTools'; }
}
