<?php

class haquery_server_HaqQuery {
	public function __construct($prefixID, $query, $nodes) {
		if(!php_Boot::$skip_constructor) {
		$this->prefixID = $prefixID;
		$this->query = $query;
		$this->nodes = (($nodes !== null) ? new _hx_array($nodes) : new _hx_array(array()));
	}}
	public $prefixID;
	public $query;
	public $nodes;
	public function jQueryCall($method) {
		haquery_server_HaqInternals::addAjaxResponse("\$('" . str_replace("#", "#" . $this->prefixID, $this->query) . "')." . $method . ";");
	}
	public function __toString() {
		return $this->nodes->join("");
	}
	public function size() {
		return $this->nodes->length;
	}
	public function get($index) {
		return $this->nodes[$index];
	}
	public function attr($name, $value) {
		if($value === null) {
			return (($this->nodes->length > 0) ? _hx_array_get($this->nodes, 0)->getAttribute($name) : null);
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
		if(haquery_server_Lib::$isPostback) {
			$this->jQueryCall("attr(\"" . $name . "\",\"" . $value . "\")");
		}
		return $this;
	}
	public function removeAttr($name) {
		{
			$_g = 0; $_g1 = $this->nodes;
			while($_g < $_g1->length) {
				$node = $_g1[$_g];
				++$_g;
				$node->removeAttribute($name);
				unset($node);
			}
		}
		if(haquery_server_Lib::$isPostback) {
			haquery_server_HaqInternals::addAjaxResponse("\$('" . str_replace("#", "#" . $this->prefixID, $this->query) . "').removeAttr('" . $name . "');");
		}
		return $this;
	}
	public function addClass($cssClass) {
		$classes = _hx_deref(new haquery_EReg("\\s+", ""))->split($cssClass);
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
		if(haquery_server_Lib::$isPostback) {
			$this->jQueryCall("addClass(\"" . $cssClass . "\")");
		}
		return $this;
	}
	public function hasClass($cssClass) {
		$classes = _hx_deref(new haquery_EReg("\\s+", ""))->split($cssClass);
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
					return true;
				}
				unset($s,$node,$inAll);
			}
		}
		return false;
	}
	public function removeClass($cssClass) {
		$classes = _hx_deref(new haquery_EReg("\\s+", ""))->split($cssClass);
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
				$node->setAttribute("class", trim($s, null));
				unset($s,$node);
			}
		}
		if(haquery_server_Lib::$isPostback) {
			$this->jQueryCall("removeClass(\"" . $cssClass . "\")");
		}
		return $this;
	}
	public function html($html, $isParse) {
		if($isParse === null) {
			$isParse = false;
		}
		if($html === null) {
			if($this->nodes->length === 0) {
				return null;
			}
			$node = $this->nodes[0];
			if(haquery_server_Lib::$isPostback && $node->name === "textarea" && $node->hasAttribute("id")) {
				$fullID = $this->prefixID . $node->getAttribute("id");
				if(php_Web::getParams()->exists($fullID)) {
					return php_Web::getParams()->get($fullID);
				}
			}
			return $node->innerHTML;
		}
		$html = Std::string($html);
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
		if(haquery_server_Lib::$isPostback) {
			$this->jQueryCall("html(\"" . haquery_StringTools::addcslashes($html) . "\")");
		}
		return $this;
	}
	public function remove() {
		{
			$_g = 0; $_g1 = $this->nodes;
			while($_g < $_g1->length) {
				$node = $_g1[$_g];
				++$_g;
				$node->remove();
				unset($node);
			}
		}
		if(haquery_server_Lib::$isPostback) {
			$this->jQueryCall("remove()");
		}
		return $this;
	}
	public function val($val) {
		if($val === null) {
			if($this->nodes->length > 0) {
				$node = $this->nodes[0];
				if(haquery_server_Lib::$isPostback && $node->hasAttribute("id")) {
					$fullID = $this->prefixID . $node->getAttribute("id");
					if(php_Web::getParams()->exists($fullID)) {
						return php_Web::getParams()->get($fullID);
					}
				}
				if($node->name === "textarea") {
					return $node->innerHTML;
				}
				if($node->name === "select") {
					$options = new _hx_array($node->find(">option"));
					{
						$_g = 0;
						while($_g < $options->length) {
							$option = $options[$_g];
							++$_g;
							if($option->hasAttribute("selected")) {
								return $option->getAttribute("value");
							}
							unset($option);
						}
					}
					return null;
				}
				if($node->name === "input" && $node->getAttribute("type") === "checkbox") {
					return $node->hasAttribute("checked");
				}
				return $node->getAttribute("value");
			} else {
				if(haquery_server_Lib::$isPostback) {
					$re = new haquery_EReg("^\\s*#([^ \\t>]+)\\s*\$", "");
					if($re->match($this->query)) {
						$fullID = $this->prefixID . $re->matched(1);
						if(php_Web::getParams()->exists($fullID)) {
							return php_Web::getParams()->get($fullID);
						}
					}
				}
			}
			return null;
		}
		{
			$_g = 0; $_g1 = $this->nodes;
			while($_g < $_g1->length) {
				$node = $_g1[$_g];
				++$_g;
				if(haquery_server_Lib::$isPostback && $node->hasAttribute("id")) {
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
								if(_hx_equal($option->getAttribute("value"), $val)) {
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
						if($node->name === "input" && $node->getAttribute("type") === "checkbox") {
							if(haquery_base_HaqTools::bool($val)) {
								$node->setAttribute("checked", "checked");
							} else {
								$node->removeAttribute("checked");
							}
						} else {
							$node->setAttribute("value", $val);
						}
					}
				}
				unset($node);
			}
		}
		if(haquery_server_Lib::$isPostback) {
			$this->jQueryCall("val(\"" . $val . "\")");
		}
		return $this;
	}
	public function css($name, $val) {
		if($val === null) {
			if($this->nodes->length > 0) {
				$sStyles = _hx_array_get($this->nodes, 0)->getAttribute("style");
				$re = new haquery_EReg("\\b(" . $name . ")\\b\\s*:\\s*(.*?)\\s*;", "");
				if($re->match($sStyles)) {
					return $re->matched(1);
				}
			}
			return null;
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
		if(haquery_server_Lib::$isPostback) {
			$this->jQueryCall("css(\"" . $name . "\",\"" . haquery_StringTools::addcslashes($val) . "\")");
		}
		return $this;
	}
	public function show($display) {
		if($display === null) {
			$display = "";
		}
		return $this->css("display", $display);
	}
	public function hide() {
		return $this->css("display", "none");
	}
	public function each($f) {
		$_g1 = 0; $_g = $this->nodes->length;
		while($_g1 < $_g) {
			$i = $_g1++;
			call_user_func_array($f, array($i, $this->get($i)));
			unset($i);
		}
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
	if($val !== "" && $val !== null) {
		return $name . ": " . $val . ";";
	} else {
		return "";
	}
}
