<?php
require_once dirname(__FILE__).'/../../haquery/server/HaqXml.extern.php';

class haquery_server_HaqTemplates {
	public function __construct($componentsFolders) {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("haquery.server.HaqTemplates::new");
		$»spos = $GLOBALS['%s']->length;
		$this->componentsFolders = $componentsFolders;
		$this->templates = new Hash();
		{
			$_g = 0;
			while($_g < $componentsFolders->length) {
				$folder = $componentsFolders[$_g];
				++$_g;
				$this->templates->set($folder, $this->build($folder));
				unset($folder);
			}
		}
		$GLOBALS['%s']->pop();
	}}
	public $componentsFolders;
	public $templates;
	public function getTags() {
		$GLOBALS['%s']->push("haquery.server.HaqTemplates::getTags");
		$»spos = $GLOBALS['%s']->length;
		$tags = new _hx_array(array());
		{
			$_g = 0; $_g1 = $this->componentsFolders;
			while($_g < $_g1->length) {
				$componentsFolder = $_g1[$_g];
				++$_g;
				{
					$_g2 = 0; $_g3 = php_FileSystem::readDirectory($componentsFolder);
					while($_g2 < $_g3->length) {
						$tag = $_g3[$_g2];
						++$_g2;
						if($tags->indexOf($tag) === -1) {
							$tags->push($tag);
						}
						unset($tag);
					}
					unset($_g3,$_g2);
				}
				unset($componentsFolder);
			}
		}
		{
			$GLOBALS['%s']->pop();
			return $tags;
		}
		$GLOBALS['%s']->pop();
	}
	public function get($tag) {
		$GLOBALS['%s']->push("haquery.server.HaqTemplates::get");
		$»spos = $GLOBALS['%s']->length;
		$r = _hx_anonymous(array("doc" => null, "serverHandlers" => null, "clas" => null));
		$i = $this->componentsFolders->length - 1;
		while($i >= 0) {
			$componentsFolder = $this->componentsFolders[$i];
			if($this->templates->exists($componentsFolder) && $this->templates->get($componentsFolder)->exists($tag)) {
				$t = $this->templates->get($componentsFolder)->get($tag);
				if($r->doc === null && $t->serializedDoc !== null) {
					$r->doc = php_Lib::unserialize($t->serializedDoc);
				}
				if($r->serverHandlers === null && $t->serverHandlers !== null) {
					$r->serverHandlers = $t->serverHandlers;
				}
				unset($t);
			}
			if($r->clas === null) {
				$className = str_replace("/", ".", haquery_server_HaqTemplates::path2relative($componentsFolder)) . $tag . ".Server";
				$r->clas = Type::resolveClass($className);
				unset($className);
			}
			$i--;
			unset($componentsFolder);
		}
		if($r->doc === null && $r->serverHandlers === null && $r->clas === null) {
			haquery_base_HaQuery::error("Component \"" . $tag . "\" not found.", _hx_anonymous(array("fileName" => "HaqTemplates.hx", "lineNumber" => 80, "className" => "haquery.server.HaqTemplates", "methodName" => "get")));
		}
		if($r->clas === null) {
			$r->clas = _hx_qtype("haquery.server.HaqComponent");
		}
		{
			$GLOBALS['%s']->pop();
			return $r;
		}
		$GLOBALS['%s']->pop();
	}
	public function build($componentsFolder) {
		$GLOBALS['%s']->push("haquery.server.HaqTemplates::build");
		$»spos = $GLOBALS['%s']->length;
		$componentsFolder = haquery_server_HaqTemplates::path2relative($componentsFolder);
		$dataFilePath = _hx_deref(_hx_anonymous(array("pages" => "pages/", "support" => "support/", "temp" => "temp/")))->temp . $componentsFolder . "components.data";
		$stylesFilePath = _hx_deref(_hx_anonymous(array("pages" => "pages/", "support" => "support/", "temp" => "temp/")))->temp . $componentsFolder . "styles.css";
		$templatePaths = haquery_server_HaqTemplates::getComponentTemplatePaths($componentsFolder);
		$cacheFileTime = haquery_server_HaqTemplates_0($this, $componentsFolder, $dataFilePath, $stylesFilePath, $templatePaths);
		if(!file_exists($dataFilePath) || Lambda::exists($templatePaths, array(new _hx_lambda(array(&$cacheFileTime, &$componentsFolder, &$dataFilePath, &$stylesFilePath, &$templatePaths), "haquery_server_HaqTemplates_1"), 'execute'))) {
			$css = "";
			$data = new Hash();
			{
				$_g = 0; $_g1 = php_FileSystem::readDirectory($componentsFolder);
				while($_g < $_g1->length) {
					$folder = $_g1[$_g];
					++$_g;
					$parts = haquery_server_HaqTemplates::parseComponent($componentsFolder . $folder);
					$css .= $parts->css;
					$data->set($folder, _hx_anonymous(array("serializedDoc" => php_Lib::serialize($parts->doc), "serverHandlers" => $parts->serverHandlers)));
					unset($parts,$folder);
				}
			}
			if(!file_exists(dirname($stylesFilePath))) {
				@mkdir(dirname($stylesFilePath), 493);
			}
			php_io_File::putContent($stylesFilePath, $css);
			php_io_File::putContent($dataFilePath, php_Lib::serialize($data));
			{
				$GLOBALS['%s']->pop();
				return $data;
			}
		} else {
			$data = php_Lib::unserialize(php_io_File::getContent($dataFilePath));
			{
				$GLOBALS['%s']->pop();
				return $data;
			}
		}
		$GLOBALS['%s']->pop();
	}
	public function getStyleFilePaths() {
		$GLOBALS['%s']->push("haquery.server.HaqTemplates::getStyleFilePaths");
		$»spos = $GLOBALS['%s']->length;
		$r = new _hx_array(array());
		{
			$_g = 0; $_g1 = $this->componentsFolders;
			while($_g < $_g1->length) {
				$folder = $_g1[$_g];
				++$_g;
				$path = _hx_deref(_hx_anonymous(array("pages" => "pages/", "support" => "support/", "temp" => "temp/")))->temp . haquery_server_HaqTemplates::path2relative($folder) . "styles.css";
				if(file_exists($path)) {
					$r->push($path);
				}
				unset($path,$folder);
			}
		}
		{
			$GLOBALS['%s']->pop();
			return $r;
		}
		$GLOBALS['%s']->pop();
	}
	public function getInternalDataForPageHtml() {
		$GLOBALS['%s']->push("haquery.server.HaqTemplates::getInternalDataForPageHtml");
		$»spos = $GLOBALS['%s']->length;
		$s = "haquery.client.HaqInternals.componentsFolders = [\x0A";
		{
			$_g = 0; $_g1 = $this->componentsFolders;
			while($_g < $_g1->length) {
				$folder = $_g1[$_g];
				++$_g;
				$s .= "    '" . haquery_server_HaqTemplates::path2relative($folder) . "',\x0A";
				unset($folder);
			}
		}
		$s = rtrim($s, "\x0A,") . "\x0A];";
		{
			$GLOBALS['%s']->pop();
			return $s;
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
	static function parseComponent($componentFolder) {
		$GLOBALS['%s']->push("haquery.server.HaqTemplates::parseComponent");
		$»spos = $GLOBALS['%s']->length;
		$componentFolder = haquery_server_HaqTemplates::path2relative($componentFolder);
		$templatePath = $componentFolder . "template.phtml";
		haquery_server_HaqProfiler::begin("HaqCache::parseComponent(): template file -> doc and css");
		$css = "";
		$doc = new HaqXml(haquery_server_HaqTemplates_2($componentFolder, $css, $templatePath));
		$i = 0;
		$children = new _hx_array($doc->children);
		while($i < $children->length) {
			$node = $children[$i];
			if($node->name === "style" && !$node->hasAttribute("id")) {
				$css .= $node->innerHTML;
				$node->remove();
				$children->splice($i, 1);
				$i--;
			}
			$i++;
			unset($node);
		}
		haquery_server_HaqProfiler::end();
		haquery_server_HaqProfiler::begin("HaqCache::parseComponent(): component server class -> handlers");
		$serverMethods = new _hx_array(array("click", "change"));
		$serverHandlers = new Hash();
		$className = str_replace("/", ".", $componentFolder) . "Server";
		$clas = Type::resolveClass($className);
		if($clas !== null) {
			$tempObj = Type::createEmptyInstance($clas);
			{
				$_g = 0; $_g1 = Type::getInstanceFields($clas);
				while($_g < $_g1->length) {
					$field = $_g1[$_g];
					++$_g;
					if(Reflect::isFunction(Reflect::field($tempObj, $field))) {
						$parts = _hx_explode("_", $field);
						if($parts->length === 2 && $serverMethods->indexOf($parts[1]) >= 0) {
							$nodeID = $parts[0];
							$method = $parts[1];
							if(!$serverHandlers->exists($nodeID)) {
								$serverHandlers->set($nodeID, new _hx_array(array()));
							}
							$serverHandlers->get($nodeID)->push($method);
							unset($nodeID,$method);
						}
						unset($parts);
					}
					unset($field);
				}
			}
		}
		haquery_server_HaqProfiler::end();
		{
			$»tmp = _hx_anonymous(array("css" => $css, "doc" => $doc, "serverHandlers" => $serverHandlers));
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getComponentTemplatePaths($componentsFolder) {
		$GLOBALS['%s']->push("haquery.server.HaqTemplates::getComponentTemplatePaths");
		$»spos = $GLOBALS['%s']->length;
		$componentsFolder = rtrim($componentsFolder, "/") . "/";
		$r = new _hx_array(array());
		$folders = php_FileSystem::readDirectory($componentsFolder);
		{
			$_g = 0;
			while($_g < $folders->length) {
				$folder = $folders[$_g];
				++$_g;
				$templatePath = $componentsFolder . $folder . "/template.phtml";
				if(file_exists($templatePath)) {
					$r->push($templatePath);
				}
				unset($templatePath,$folder);
			}
		}
		{
			$GLOBALS['%s']->pop();
			return $r;
		}
		$GLOBALS['%s']->pop();
	}
	static function path2relative($path) {
		$GLOBALS['%s']->push("haquery.server.HaqTemplates::path2relative");
		$»spos = $GLOBALS['%s']->length;
		$path = rtrim(str_replace("\\", "/", realpath($path)), "/");
		$basePath = rtrim(str_replace("\\", "/", realpath("")), "/");
		if(!_hx_starts_with($path, $basePath)) {
			haquery_base_HaQuery::error("path2relative with path = " . $path, _hx_anonymous(array("fileName" => "HaqTemplates.hx", "lineNumber" => 223, "className" => "haquery.server.HaqTemplates", "methodName" => "path2relative")));
		}
		$path = _hx_substr($path, strlen($basePath) + 1, null);
		{
			$»tmp = haquery_server_HaqTemplates_3($basePath, $path);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getTemplateText($path) {
		$GLOBALS['%s']->push("haquery.server.HaqTemplates::getTemplateText");
		$»spos = $GLOBALS['%s']->length;
		ob_start();
		include($path);
		$text = ob_get_clean();
		$supportUrl = "/" . haquery_server_HaqTemplates::path2relative(dirname($path)) . "support/";
		$text = str_replace("~/", $supportUrl, $text);
		{
			$GLOBALS['%s']->pop();
			return $text;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'haquery.server.HaqTemplates'; }
}
function haquery_server_HaqTemplates_0(&$»this, &$componentsFolder, &$dataFilePath, &$stylesFilePath, &$templatePaths) {
	if(file_exists($dataFilePath)) {
		return php_FileSystem::stat($dataFilePath)->mtime->getTime();
	} else {
		return 0.0;
	}
}
function haquery_server_HaqTemplates_1(&$cacheFileTime, &$componentsFolder, &$dataFilePath, &$stylesFilePath, &$templatePaths, $path) {
	{
		$GLOBALS['%s']->push("haquery.server.HaqTemplates::build@100");
		$»spos2 = $GLOBALS['%s']->length;
		{
			$»tmp = php_FileSystem::stat($path)->mtime->getTime() > $cacheFileTime;
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
}
function haquery_server_HaqTemplates_2(&$componentFolder, &$css, &$templatePath) {
	if(file_exists($templatePath)) {
		return haquery_server_HaqTemplates::getTemplateText($templatePath);
	} else {
		return "";
	}
}
function haquery_server_HaqTemplates_3(&$basePath, &$path) {
	if(strlen($path) > 0) {
		return $path . "/";
	} else {
		return "";
	}
}
