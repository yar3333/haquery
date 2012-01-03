<?php

class TrmTools {
	public function __construct(){}
	static function capitalize($s) {
		$GLOBALS['%s']->push("TrmTools::capitalize");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = TrmTools_0($s);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function indent($text, $ind) {
		$GLOBALS['%s']->push("TrmTools::indent");
		$»spos = $GLOBALS['%s']->length;
		if($ind === null) {
			$ind = "\x09";
		}
		if($text === "") {
			$GLOBALS['%s']->pop();
			return "";
		}
		{
			$»tmp = $ind . str_replace("\x0A", "\x0A" . $ind, $text);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function splitFullClassName($fullClassName) {
		$GLOBALS['%s']->push("TrmTools::splitFullClassName");
		$»spos = $GLOBALS['%s']->length;
		$packageName = "";
		$className = $fullClassName;
		if(_hx_last_index_of($fullClassName, ".", null) !== -1) {
			$packageName = _hx_substr($fullClassName, 0, _hx_last_index_of($fullClassName, ".", null));
			$className = _hx_substr($fullClassName, _hx_last_index_of($fullClassName, ".", null) + 1, null);
		}
		{
			$»tmp = _hx_anonymous(array("packageName" => $packageName, "className" => $className));
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function createVar($name, $type, $defVal) {
		$GLOBALS['%s']->push("TrmTools::createVar");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = _hx_anonymous(array("name" => $name, "type" => $type, "defVal" => $defVal));
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static $classPaths;
	static function getClassPaths() {
		$GLOBALS['%s']->push("TrmTools::getClassPaths");
		$»spos = $GLOBALS['%s']->length;
		if(TrmTools::$classPaths === null) {
			TrmTools::$classPaths = new _hx_array(array(TrmTools_1() . "/"));
			$files = php_FileSystem::readDirectory(".");
			{
				$_g = 0;
				while($_g < $files->length) {
					$file = $files[$_g];
					++$_g;
					if(StringTools::endsWith($file, ".hxproj")) {
						$text = php_io_File::getContent($file);
						$text = str_replace("<?xml version=\"1.0\" encoding=\"utf-8\"?>", "", $text);
						$xml = Xml::parse($text);
						$fast = new haxe_xml_Fast($xml->firstElement());
						if($fast->hasNode->resolve("classpaths")) {
							$cp = $fast->node->resolve("classpaths");
							if(null == $cp) throw new HException('null iterable');
							$»it = $cp->getElements();
							while($»it->hasNext()) {
								$elem = $»it->next();
								if($elem->getName() === "class" && $elem->has->resolve("path")) {
									TrmTools::$classPaths->push(rtrim(str_replace("\\", "/", $elem->att->resolve("path")), "/") . "/");
								}
							}
							unset($cp);
						}
						unset($xml,$text,$fast);
					}
					unset($file);
				}
			}
		}
		{
			$»tmp = TrmTools::$classPaths;
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'TrmTools'; }
}
function TrmTools_0(&$s) {
	$»spos = $GLOBALS['%s']->length;
	if(strlen($s) === 0) {
		return $s;
	} else {
		return strtoupper(_hx_substr($s, 0, 1)) . _hx_substr($s, 1, null);
	}
}
function TrmTools_1() {
	$»spos = $GLOBALS['%s']->length;
	{
		$p = realpath("../..");
		if(($p === false)) {
			return null;
		} else {
			return $p;
		}
		unset($p);
	}
}
