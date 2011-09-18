<?php
require_once dirname(__FILE__).'/../../HaqXml.extern.php';

class haquery_server_HaqTemplates {
	public function __construct($componentsFolders) {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("haquery.server.HaqTemplates::new");
		$»spos = $GLOBALS['%s']->length;
		$this->componentsFolders = new _hx_array(array());
		{
			$_g = 0;
			while($_g < $componentsFolders->length) {
				$folder = $componentsFolders[$_g];
				++$_g;
				$path = rtrim(str_replace("\\", "/", $folder), "/") . "/";
				if(!is_dir($path)) {
					throw new HException("Components directory '" . $folder . "' do not exists.");
				}
				$this->componentsFolders->push($path);
				unset($path,$folder);
			}
		}
		$this->templates = new Hash();
		{
			$_g = 0; $_g1 = $this->componentsFolders;
			while($_g < $_g1->length) {
				$folder = $_g1[$_g];
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
						if(!Lambda::has($tags, $tag, null)) {
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
		$r = _hx_anonymous(array("doc" => null, "serverHandlers" => null, "serverClass" => null));
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
			if($r->serverClass === null) {
				$className = str_replace("/", ".", $componentsFolder) . $tag . ".Server";
				$r->serverClass = Type::resolveClass($className);
				unset($className);
			}
			$i--;
			unset($componentsFolder);
		}
		if($r->doc === null && $r->serverHandlers === null && $r->serverClass === null) {
			throw new HException("Component \"" . $tag . "\" not found.");
		}
		if($r->serverClass === null) {
			$r->serverClass = _hx_qtype("haquery.server.HaqComponent");
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
		$dataFilePath = haquery_base_HaQuery::$folders->temp . "/" . $componentsFolder . "components.data";
		$stylesFilePath = haquery_base_HaQuery::$folders->temp . "/" . $componentsFolder . "styles.css";
		$templatePaths = $this->getComponentTemplatePaths($componentsFolder);
		$cacheFileTime = ((file_exists($dataFilePath)) ? php_FileSystem::stat($dataFilePath)->mtime->getTime() : 0.0);
		if(!file_exists($dataFilePath) || Lambda::exists($templatePaths, array(new _hx_lambda(array(&$cacheFileTime, &$componentsFolder, &$dataFilePath, &$stylesFilePath, &$templatePaths), "haquery_server_HaqTemplates_0"), 'execute'))) {
			haxe_Log::trace("HAQUERY rebuilding components", _hx_anonymous(array("fileName" => "HaqTemplates.hx", "lineNumber" => 105, "className" => "haquery.server.HaqTemplates", "methodName" => "build")));
			$css = "";
			$data = new Hash();
			{
				$_g = 0; $_g1 = php_FileSystem::readDirectory($componentsFolder);
				while($_g < $_g1->length) {
					$folder = $_g1[$_g];
					++$_g;
					$parts = $this->parseComponent($componentsFolder . $folder);
					$serverHandlers = $this->parseServerHandlers($componentsFolder . $folder);
					$css .= $parts->css;
					$data->set($folder, _hx_anonymous(array("serializedDoc" => php_Lib::serialize($parts->doc), "serverHandlers" => $serverHandlers)));
					unset($serverHandlers,$parts,$folder);
				}
			}
			if(!file_exists(dirname($stylesFilePath))) {
				$this->createDirectory(dirname($stylesFilePath));
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
	public function parseComponent($componentFolder) {
		$GLOBALS['%s']->push("haquery.server.HaqTemplates::parseComponent");
		$»spos = $GLOBALS['%s']->length;
		HaqProfiler::begin("HaqTemplate::parseComponent(): template file -> doc and css");
		$tag = basename($componentFolder);
		$doc = $this->getComponentTemplateDoc($tag);
		$css = "";
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
		HaqProfiler::end();
		{
			$»tmp = _hx_anonymous(array("css" => $css, "doc" => $doc));
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function parseServerHandlers($componentFolder) {
		$GLOBALS['%s']->push("haquery.server.HaqTemplates::parseServerHandlers");
		$»spos = $GLOBALS['%s']->length;
		$componentFolder = rtrim($componentFolder, "/") . "/";
		HaqProfiler::begin("HaqTemplate::parseComponent(): component server class -> handlers");
		$serverMethods = new _hx_array(array("click", "change"));
		$serverHandlers = new Hash();
		$className = str_replace("/", ".", $componentFolder) . "Server";
		$clas = Type::resolveClass($className);
		if($clas === null) {
			$GLOBALS['%s']->pop();
			return null;
		}
		$tempObj = Type::createEmptyInstance($clas);
		{
			$_g = 0; $_g1 = Type::getInstanceFields($clas);
			while($_g < $_g1->length) {
				$field = $_g1[$_g];
				++$_g;
				if(Reflect::isFunction(Reflect::field($tempObj, $field))) {
					$parts = _hx_explode("_", $field);
					if($parts->length === 2 && Lambda::has($serverMethods, $parts[1], null)) {
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
		HaqProfiler::end();
		{
			$GLOBALS['%s']->pop();
			return $serverHandlers;
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
				$path = haquery_base_HaQuery::$folders->temp . "/" . $folder . "styles.css";
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
	public function getFileUrl($tag, $filePathRelativeToComponentFolder) {
		$GLOBALS['%s']->push("haquery.server.HaqTemplates::getFileUrl");
		$»spos = $GLOBALS['%s']->length;
		$filePathRelativeToComponentFolder = rtrim($filePathRelativeToComponentFolder, "/");
		$i = $this->componentsFolders->length - 1;
		while($i >= 0) {
			$path = $this->componentsFolders[$i] . $tag . "/" . $filePathRelativeToComponentFolder;
			if(file_exists($path)) {
				$GLOBALS['%s']->pop();
				return $path;
			}
			$i--;
			unset($path);
		}
		{
			$GLOBALS['%s']->pop();
			return null;
		}
		$GLOBALS['%s']->pop();
	}
	public function getFileUrls($tag, $filePathRelativeToComponentFolder) {
		$GLOBALS['%s']->push("haquery.server.HaqTemplates::getFileUrls");
		$»spos = $GLOBALS['%s']->length;
		$urls = new _hx_array(array());
		$filePathRelativeToComponentFolder = rtrim($filePathRelativeToComponentFolder, "/");
		{
			$_g = 0; $_g1 = $this->componentsFolders;
			while($_g < $_g1->length) {
				$componentsFolder = $_g1[$_g];
				++$_g;
				$path = $componentsFolder . $tag . "/" . $filePathRelativeToComponentFolder;
				if(file_exists($path)) {
					$urls->push($path);
				}
				unset($path,$componentsFolder);
			}
		}
		{
			$GLOBALS['%s']->pop();
			return $urls;
		}
		$GLOBALS['%s']->pop();
	}
	public function getComponentTemplatePaths($componentsFolder) {
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
				$templatePath = $componentsFolder . $folder . "/template.html";
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
	public function getPageTemplateDoc($pageFolder) {
		$GLOBALS['%s']->push("haquery.server.HaqTemplates::getPageTemplateDoc");
		$»spos = $GLOBALS['%s']->length;
		$pageFolder = rtrim($pageFolder, "/") . "/";
		$templatePath = $pageFolder . "template.html";
		$pageText = ((file_exists($templatePath)) ? php_io_File::getContent($templatePath) : "");
		$pageDoc = new HaqXml($pageText);
		if(haquery_base_HaQuery::$config->layout === null) {
			$GLOBALS['%s']->pop();
			return $pageDoc;
		}
		if(!file_exists(haquery_base_HaQuery::$config->layout)) {
			throw new HException("Layout file '" . haquery_base_HaQuery::$config->layout . "' not found.");
		}
		$layoutDoc = new HaqXml(php_io_File::getContent(haquery_base_HaQuery::$config->layout));
		$placeholders = new _hx_array($layoutDoc->find("haq:placeholder"));
		$contents = new _hx_array($pageDoc->find(">haq:content"));
		{
			$_g = 0;
			while($_g < $placeholders->length) {
				$ph = $placeholders[$_g];
				++$_g;
				$content = null;
				{
					$_g1 = 0;
					while($_g1 < $contents->length) {
						$c = $contents[$_g1];
						++$_g1;
						if($c->getAttribute("id") === $ph->getAttribute("id")) {
							$content = $c;
							break;
						}
						unset($c);
					}
					unset($_g1);
				}
				if($content !== null) {
					$ph->parent->replaceChildWithInner($ph, $content);
				} else {
					$ph->parent->replaceChildWithInner($ph, $ph);
				}
				unset($ph,$content);
			}
		}
		{
			$GLOBALS['%s']->pop();
			return $layoutDoc;
		}
		$GLOBALS['%s']->pop();
	}
	public function getComponentTemplateDoc($tag) {
		$GLOBALS['%s']->push("haquery.server.HaqTemplates::getComponentTemplateDoc");
		$»spos = $GLOBALS['%s']->length;
		$files = $this->getFileUrls($tag, "template.html");
		$text = Lambda::map($files, (isset(php_io_File::$getContent) ? php_io_File::$getContent: array("php_io_File", "getContent")))->join("");
		$self = $this;
		$reSupportFileUrl = new haquery_EReg("~/([-_/\\.a-zA-Z0-9]*)", "");
		$text = $reSupportFileUrl->customReplace($text, array(new _hx_lambda(array(&$files, &$reSupportFileUrl, &$self, &$tag, &$text), "haquery_server_HaqTemplates_1"), 'execute'));
		{
			$»tmp = new HaqXml($text);
			$GLOBALS['%s']->pop();
			return $»tmp;
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
				$s .= "    '" . $folder . "',\x0A";
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
	public function createDirectory($path) {
		$GLOBALS['%s']->push("haquery.server.HaqTemplates::createDirectory");
		$»spos = $GLOBALS['%s']->length;
		$parentPath = dirname($path);
		if($parentPath !== null && $parentPath !== "" && !file_exists($parentPath)) {
			$this->createDirectory($parentPath);
		}
		@mkdir($path, 493);
		$GLOBALS['%s']->pop();
	}
	public function getSupportPath($tag) {
		$GLOBALS['%s']->push("haquery.server.HaqTemplates::getSupportPath");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $this->getFileUrl($tag, haquery_base_HaQuery::$folders->support) . "/";
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
	function __toString() { return 'haquery.server.HaqTemplates'; }
}
function haquery_server_HaqTemplates_0(&$cacheFileTime, &$componentsFolder, &$dataFilePath, &$stylesFilePath, &$templatePaths, $path) {
	$»spos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("haquery.server.HaqTemplates::build@103");
		$»spos2 = $GLOBALS['%s']->length;
		{
			$»tmp = php_FileSystem::stat($path)->mtime->getTime() > $cacheFileTime;
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
}
function haquery_server_HaqTemplates_1(&$files, &$reSupportFileUrl, &$self, &$tag, &$text, $re) {
	$»spos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("haquery.server.HaqTemplates::getComponentTemplateDoc@297");
		$»spos2 = $GLOBALS['%s']->length;
		$f = $self->getFileUrl($tag, haquery_base_HaQuery::$folders->support . "/" . $re->matched(1));
		{
			$»tmp = haquery_server_HaqTemplates_2($»this, $f, $files, $re, $reSupportFileUrl, $self, $tag, $text);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
}
function haquery_server_HaqTemplates_2(&$»this, &$f, &$files, &$re, &$reSupportFileUrl, &$self, &$tag, &$text) {
	$»spos = $GLOBALS['%s']->length;
	if($f !== null) {
		return "/" . $f;
	} else {
		return $re->matched(0);
	}
}
