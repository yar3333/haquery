<?php

class haquery_server_HaqQuery {
	public function __construct($prefixID, $query, $nodes) {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("haquery.server.HaqQuery::new");
		$»spos = $GLOBALS['%s']->length;
		$this->prefixID = $prefixID;
		$this->query = $query;
		$this->nodes = (($nodes !== null) ? new _hx_array($nodes) : new _hx_array(array()));
		$GLOBALS['%s']->pop();
	}}
	public $prefixID;
	public $query;
	public $nodes;
	public function jQueryCall($method) {
		$GLOBALS['%s']->push("haquery.server.HaqQuery::jQueryCall");
		$»spos = $GLOBALS['%s']->length;
		haquery_server_HaqInternals::addAjaxAnswer("\$('" . str_replace("#", "#" . $this->prefixID, $this->query) . "')." . $method . ";");
		$GLOBALS['%s']->pop();
	}
	public function __toString() {
		$GLOBALS['%s']->push("haquery.server.HaqQuery::__toString");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $this->nodes->join("");
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function size() {
		$GLOBALS['%s']->push("haquery.server.HaqQuery::size");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $this->nodes->length;
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function get($index) {
		$GLOBALS['%s']->push("haquery.server.HaqQuery::get");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $this->nodes[$index];
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function attr($name, $value) {
		$GLOBALS['%s']->push("haquery.server.HaqQuery::attr");
		$»spos = $GLOBALS['%s']->length;
		if(($value === null)) {
			$»tmp = (($this->nodes->length > 0) ? _hx_array_get($this->nodes, 0)->getAttribute($name) : null);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		{
			$_g = 0; $_g1 = $this->nodes;
			while($_g < $_g1->length) {
				$node = $_g1[$_g];
				++$_g;
				$node->setAttribute($name, $value);
				unset($node);
			}
		}
		if(haquery_base_HaQuery::$isPostback) {
			$this->jQueryCall("attr(\"" . $name . "\",\"" . $value . "\")");
		}
		{
			$GLOBALS['%s']->pop();
			return $this;
		}
		$GLOBALS['%s']->pop();
	}
	public function removeAttr($name) {
		$GLOBALS['%s']->push("haquery.server.HaqQuery::removeAttr");
		$»spos = $GLOBALS['%s']->length;
		{
			$_g = 0; $_g1 = $this->nodes;
			while($_g < $_g1->length) {
				$node = $_g1[$_g];
				++$_g;
				$node->removeAttribute($name);
				unset($node);
			}
		}
		if(haquery_base_HaQuery::$isPostback) {
			haquery_server_HaqInternals::addAjaxAnswer("\$('" . str_replace("#", "#" . $this->prefixID, $this->query) . "').removeAttr('" . $name . "');");
		}
		{
			$GLOBALS['%s']->pop();
			return $this;
		}
		$GLOBALS['%s']->pop();
	}
	public function addClass($clas) {
		$GLOBALS['%s']->push("haquery.server.HaqQuery::addClass");
		$»spos = $GLOBALS['%s']->length;
		$classes = _hx_deref(new haquery_EReg("\\s+", ""))->split($clas);
		{
			$_g = 0; $_g1 = $this->nodes;
			while($_g < $_g1->length) {
				$node = $_g1[$_g];
				++$_g;
				$s = (($node->hasAttribute("class")) ? $node->getAttribute("class") : "");
				{
					$_g2 = 0;
					while($_g2 < $classes->length) {
						$c = $classes[$_g2];
						++$_g2;
						if(!_hx_deref(new haquery_EReg("(^|\\s)" . $c . "(\\s|\$)", ""))->match($s)) {
							$s .= " " . $c;
						}
						unset($c);
					}
					unset($_g2);
				}
				$node->setAttribute("class", ltrim($s, null));
				unset($s,$node);
			}
		}
		if(haquery_base_HaQuery::$isPostback) {
			$this->jQueryCall("addClass(\"" . $clas . "\")");
		}
		{
			$GLOBALS['%s']->pop();
			return $this;
		}
		$GLOBALS['%s']->pop();
	}
	public function hasClass($clas) {
		$GLOBALS['%s']->push("haquery.server.HaqQuery::hasClass");
		$»spos = $GLOBALS['%s']->length;
		$classes = _hx_deref(new haquery_EReg("\\s+", ""))->split($clas);
		{
			$_g = 0; $_g1 = $this->nodes;
			while($_g < $_g1->length) {
				$node = $_g1[$_g];
				++$_g;
				$s = (($node->hasAttribute("class")) ? $node->getAttribute("class") : "");
				$inAll = true;
				{
					$_g2 = 0;
					while($_g2 < $classes->length) {
						$c = $classes[$_g2];
						++$_g2;
						if(!_hx_deref(new haquery_EReg("(^|\\s)" . $c . "(\\s|\$)", ""))->match($s)) {
							$inAll = false;
							break;
						}
						unset($c);
					}
					unset($_g2);
				}
				if($inAll) {
					$GLOBALS['%s']->pop();
					return true;
				}
				unset($s,$node,$inAll);
			}
		}
		{
			$GLOBALS['%s']->pop();
			return false;
		}
		$GLOBALS['%s']->pop();
	}
	public function removeClass($clas) {
		$GLOBALS['%s']->push("haquery.server.HaqQuery::removeClass");
		$»spos = $GLOBALS['%s']->length;
		$classes = _hx_deref(new haquery_EReg("\\s+", ""))->split($clas);
		{
			$_g = 0; $_g1 = $this->nodes;
			while($_g < $_g1->length) {
				$node = $_g1[$_g];
				++$_g;
				$s = (($node->hasAttribute("class")) ? $node->getAttribute("class") : "");
				{
					$_g2 = 0;
					while($_g2 < $classes->length) {
						$c = $classes[$_g2];
						++$_g2;
						$s = _hx_deref(new haquery_EReg("(^|\\s)" . $c . "(\\s|\$)", ""))->replace($s, " ");
						unset($c);
					}
					unset($_g2);
				}
				$node->setAttribute("class", rtrim($s, null));
				unset($s,$node);
			}
		}
		if(haquery_base_HaQuery::$isPostback) {
			$this->jQueryCall("removeClass(\"" . $clas . "\")");
		}
		{
			$GLOBALS['%s']->pop();
			return $this;
		}
		$GLOBALS['%s']->pop();
	}
	public function html($html, $isParse) {
		$GLOBALS['%s']->push("haquery.server.HaqQuery::html");
		$»spos = $GLOBALS['%s']->length;
		if($isParse === null) {
			$isParse = false;
		}
		if(($html === null)) {
			if($this->nodes->length === 0) {
				$GLOBALS['%s']->pop();
				return null;
			}
			$node = $this->nodes[0];
			if(haquery_base_HaQuery::$isPostback && $node->name === "textarea" && $node->hasAttribute("id")) {
				$fullID = $this->prefixID . $node->getAttribute("id");
				if(php_Web::getParams()->exists($fullID)) {
					$»tmp = php_Web::getParams()->get($fullID);
					$GLOBALS['%s']->pop();
					return $»tmp;
				}
			}
			{
				$»tmp = $node->innerHTML;
				$GLOBALS['%s']->pop();
				return $»tmp;
			}
		}
		{
			$_g = 0; $_g1 = $this->nodes;
			while($_g < $_g1->length) {
				$node = $_g1[$_g];
				++$_g;
				if($isParse) {
					$node->innerHTML = $html;
				} else {
					$node->setInnerText($html);
				}
				unset($node);
			}
		}
		if(haquery_base_HaQuery::$isPostback) {
			$this->jQueryCall("html(\"" . haquery_base_HaQuery::jsEscape($html) . "\")");
		}
		{
			$GLOBALS['%s']->pop();
			return $this;
		}
		$GLOBALS['%s']->pop();
	}
	public function remove() {
		$GLOBALS['%s']->push("haquery.server.HaqQuery::remove");
		$»spos = $GLOBALS['%s']->length;
		{
			$_g = 0; $_g1 = $this->nodes;
			while($_g < $_g1->length) {
				$node = $_g1[$_g];
				++$_g;
				$node->remove();
				unset($node);
			}
		}
		if(haquery_base_HaQuery::$isPostback) {
			$this->jQueryCall("remove()");
		}
		{
			$GLOBALS['%s']->pop();
			return $this;
		}
		$GLOBALS['%s']->pop();
	}
	public function val($val) {
		$GLOBALS['%s']->push("haquery.server.HaqQuery::val");
		$»spos = $GLOBALS['%s']->length;
		if(($val === null)) {
			if($this->nodes->length > 0) {
				$node = $this->nodes[0];
				if(haquery_base_HaQuery::$isPostback && $node->hasAttribute("id")) {
					$fullID = $this->prefixID . $node->getAttribute("id");
					if(php_Web::getParams()->exists($fullID)) {
						$»tmp = php_Web::getParams()->get($fullID);
						$GLOBALS['%s']->pop();
						return $»tmp;
					}
				}
				if($node->name === "textarea") {
					$»tmp = $node->innerHTML;
					$GLOBALS['%s']->pop();
					return $»tmp;
				}
				if($node->name === "select") {
					$options = new _hx_array($node->find(">option"));
					{
						$_g = 0;
						while($_g < $options->length) {
							$option = $options[$_g];
							++$_g;
							if($option->hasAttribute("selected")) {
								$»tmp = $option->getAttribute("value");
								$GLOBALS['%s']->pop();
								return $»tmp;
								unset($»tmp);
							}
							unset($option);
						}
					}
					{
						$GLOBALS['%s']->pop();
						return null;
					}
				}
				{
					$»tmp = $node->getAttribute("value");
					$GLOBALS['%s']->pop();
					return $»tmp;
				}
			}
			{
				$GLOBALS['%s']->pop();
				return null;
			}
		}
		{
			$_g = 0; $_g1 = $this->nodes;
			while($_g < $_g1->length) {
				$node = $_g1[$_g];
				++$_g;
				if(haquery_base_HaQuery::$isPostback && $node->hasAttribute("id")) {
					$fullID = $this->prefixID . $node->getAttribute("id");
					
					if (isset($_POST[$fullID])) $_POST[$fullID] = $val; 
				;
					unset($fullID);
				}
				if($node->name === "textarea") {
					$node->innerHTML = $val;
				} else {
					if($node->name === "select") {
						$options = new _hx_array($node->find(">option"));
						{
							$_g2 = 0;
							while($_g2 < $options->length) {
								$option = $options[$_g2];
								++$_g2;
								if($option->getAttribute("value") === $val) {
									$option->setAttribute("selected", "selected");
								} else {
									$option->removeAttribute("selected");
								}
								unset($option);
							}
							unset($_g2);
						}
						unset($options);
					} else {
						$node->setAttribute("value", $val);
					}
				}
				unset($node);
			}
		}
		if(haquery_base_HaQuery::$isPostback) {
			$this->jQueryCall("val(\"" . $val . "\")");
		}
		{
			$GLOBALS['%s']->pop();
			return $this;
		}
		$GLOBALS['%s']->pop();
	}
	public function css($name, $val) {
		$GLOBALS['%s']->push("haquery.server.HaqQuery::css");
		$»spos = $GLOBALS['%s']->length;
		if(($val === null)) {
			if($this->nodes->length > 0) {
				$sStyles = _hx_array_get($this->nodes, 0)->getAttribute("style");
				$re = new haquery_EReg("\\b(" . $name . ")\\b\\s*:\\s*(.*?)\\s*;", "");
				if($re->match($sStyles)) {
					$»tmp = $re->matched(1);
					$GLOBALS['%s']->pop();
					return $»tmp;
				}
			}
			{
				$GLOBALS['%s']->pop();
				return null;
			}
		}
		$re = new haquery_EReg("\\b(" . $name . ")\\b\\s*:\\s*(.*?)\\s*(;|\$)", "");
		{
			$_g = 0; $_g1 = $this->nodes;
			while($_g < $_g1->length) {
				$node = $_g1[$_g];
				++$_g;
				$sStyles = _hx_array_get($this->nodes, 0)->getAttribute("style");
				if($re->match($sStyles)) {
					$sStyles = $re->replace(haquery_server_HaqQuery_0($this, $_g, $_g1, $name, $node, $re, $sStyles, $val), $sStyles);
				} else {
					if(!($val === "") && !($val === null)) {
						$sStyles = $name . ": " . $val . "; " . $sStyles;
					}
				}
				_hx_array_get($this->nodes, 0)->setAttribute("style", $sStyles);
				unset($sStyles,$node);
			}
		}
		if(haquery_base_HaQuery::$isPostback) {
			$this->jQueryCall("css(\"" . $name . "\",\"" . haquery_base_HaQuery::jsEscape($val) . "\")");
		}
		{
			$GLOBALS['%s']->pop();
			return $this;
		}
		$GLOBALS['%s']->pop();
	}
	public function show($display) {
		$GLOBALS['%s']->push("haquery.server.HaqQuery::show");
		$»spos = $GLOBALS['%s']->length;
		if($display === null) {
			$display = "";
		}
		{
			$»tmp = $this->css("display", $display);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function hide() {
		$GLOBALS['%s']->push("haquery.server.HaqQuery::hide");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $this->css("display", "none");
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function each($f) {
		$GLOBALS['%s']->push("haquery.server.HaqQuery::each");
		$»spos = $GLOBALS['%s']->length;
		$_g1 = 0; $_g = $this->nodes->length;
		while($_g1 < $_g) {
			$i = $_g1++;
			call_user_func_array($f, array($i, $this->get($i)));
			unset($i);
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
}
function haquery_server_HaqQuery_0(&$»this, &$_g, &$_g1, &$name, &$node, &$re, &$sStyles, &$val) {
	$»spos = $GLOBALS['%s']->length;
	if(!($val === "") && !($val === null)) {
		return $name . ": " . $val . ";";
	} else {
		return "";
	}
}
