<?php
require_once dirname(__FILE__).'/../../Lessc.extern.php';
require_once dirname(__FILE__).'/../../HaqXml.extern.php';

class haquery_server_HaqTemplates {
	public function __construct($componentsFolders) {
		if(!php_Boot::$skip_constructor) {
		$this->componentsFolders = $componentsFolders;
		$this->templates = new Hash();
		{
			$_g = 0;
			while($_g < $componentsFolders->length) {
				$folder = $componentsFolders[$_g];
				++$_g;
				null;
				$this->templates->set($folder, $this->build($folder));
				unset($folder);
			}
		}
	}}
	public $componentsFolders;
	public $templates;
	public function getTags() {
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
		return $tags;
	}
	public function get($tag) {
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
		return $r;
	}
	public function build($componentsFolder) {
		$dataFilePath = haquery_base_HaqDefines::$folders->temp . "/" . $componentsFolder . "components.data";
		$stylesFilePath = haquery_base_HaqDefines::$folders->temp . "/" . $componentsFolder . "styles.css";
		$templatePaths = $this->getComponentTemplatePaths($componentsFolder);
		$cacheFileTime = ((file_exists($dataFilePath)) ? php_FileSystem::stat($dataFilePath)->mtime->getTime() : 0.0);
		if(!file_exists($dataFilePath) || Lambda::exists($templatePaths, array(new _hx_lambda(array(&$cacheFileTime, &$componentsFolder, &$dataFilePath, &$stylesFilePath, &$templatePaths), "haquery_server_HaqTemplates_0"), 'execute'))) {
			haxe_Log::trace("HAQUERY rebuilding components", _hx_anonymous(array("fileName" => "HaqTemplates.hx", "lineNumber" => 99, "className" => "haquery.server.HaqTemplates", "methodName" => "build")));
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
			return $data;
		} else {
			$data = php_Lib::unserialize(php_io_File::getContent($dataFilePath));
			return $data;
		}
	}
	public function parseComponent($componentFolder) {
		null;
		$lessc = new Lessc(null);
		$tag = basename($componentFolder);
		$doc = $this->getComponentTemplateDoc($tag);
		$css = "";
		$i = 0;
		$children = new _hx_array($doc->children);
		while($i < $children->length) {
			$node = $children[$i];
			if($node->name === "style" && !$node->hasAttribute("id")) {
				if($node->getAttribute("type") === "text/less") {
					$css .= $lessc->parse($node->innerHTML);
				} else {
					$css .= $node->innerHTML;
				}
				$node->remove();
				$children->splice($i, 1);
				$i--;
			}
			$i++;
			unset($node);
		}
		null;
		return _hx_anonymous(array("css" => $css, "doc" => $doc));
	}
	public function parseServerHandlers($componentFolder) {
		$componentFolder = rtrim($componentFolder, "/") . "/";
		null;
		$serverMethods = new _hx_array(array("click", "change"));
		$serverHandlers = new Hash();
		$className = str_replace("/", ".", $componentFolder) . "Server";
		$clas = Type::resolveClass($className);
		if($clas === null) {
			null;
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
		null;
		return $serverHandlers;
	}
	public function getStyleFilePaths() {
		$r = new _hx_array(array());
		{
			$_g = 0; $_g1 = $this->componentsFolders;
			while($_g < $_g1->length) {
				$folder = $_g1[$_g];
				++$_g;
				$lessPath = haquery_base_HaqDefines::$folders->temp . "/" . $folder . "styles.less";
				$cssPath = haquery_base_HaqDefines::$folders->temp . "/" . $folder . "styles.css";
				if(file_exists($lessPath)) {
					if(!file_exists($cssPath) || php_FileSystem::stat($lessPath)->mtime->getTime() > php_FileSystem::stat($cssPath)->mtime->getTime()) {
						Lessc::ccompile($lessPath, $cssPath);
					}
				}
				if(file_exists($cssPath)) {
					$r->push($cssPath);
				}
				unset($lessPath,$folder,$cssPath);
			}
		}
		return $r;
	}
	public function getFileUrl($tag, $filePathRelativeToComponentFolder) {
		$filePathRelativeToComponentFolder = trim($filePathRelativeToComponentFolder, "/");
		$i = $this->componentsFolders->length - 1;
		while($i >= 0) {
			$path = $this->componentsFolders[$i] . $tag . "/" . $filePathRelativeToComponentFolder;
			if(file_exists($path)) {
				return $path;
			}
			$i--;
			unset($path);
		}
		return null;
	}
	public function getFileUrls($tag, $filePathRelativeToComponentFolder) {
		$urls = new _hx_array(array());
		$filePathRelativeToComponentFolder = trim($filePathRelativeToComponentFolder, "/");
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
		return $urls;
	}
	public function getComponentTemplatePaths($componentsFolder) {
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
		return $r;
	}
	public function getPageTemplateDoc($pageFolder) {
		$pageFolder = rtrim($pageFolder, "/") . "/";
		$templatePath = $pageFolder . "template.html";
		$pageText = ((file_exists($templatePath)) ? php_io_File::getContent($templatePath) : "");
		$pageDoc = new HaqXml($pageText);
		if(haquery_server_Lib::$config->layout === null || haquery_server_Lib::$config->layout === "") {
			return $pageDoc;
		}
		if(!file_exists(haquery_server_Lib::$config->layout)) {
			throw new HException("Layout file '" . haquery_server_Lib::$config->layout . "' not found.");
		}
		$layoutDoc = new HaqXml(php_io_File::getContent(haquery_server_Lib::$config->layout));
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
		return $layoutDoc;
	}
	public function getComponentTemplateDoc($tag) {
		$files = $this->getFileUrls($tag, "template.html");
		$text = Lambda::map($files, (isset(php_io_File::$getContent) ? php_io_File::$getContent: array("php_io_File", "getContent")))->join("");
		$self = $this;
		$reSupportFileUrl = new haquery_EReg("~/([-_/\\.a-zA-Z0-9]*)", "");
		$text = $reSupportFileUrl->customReplace($text, array(new _hx_lambda(array(&$files, &$reSupportFileUrl, &$self, &$tag, &$text), "haquery_server_HaqTemplates_1"), 'execute'));
		return new HaqXml($text);
	}
	public function getInternalDataForPageHtml() {
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
		return $s;
	}
	public function createDirectory($path) {
		$parentPath = dirname($path);
		if($parentPath !== null && $parentPath !== "" && !file_exists($parentPath)) {
			$this->createDirectory($parentPath);
		}
		@mkdir($path, 493);
	}
	public function getSupportPath($tag) {
		return $this->getFileUrl($tag, haquery_base_HaqDefines::$folders->support) . "/";
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
	{
		return php_FileSystem::stat($path)->mtime->getTime() > $cacheFileTime;
	}
}
function haquery_server_HaqTemplates_1(&$files, &$reSupportFileUrl, &$self, &$tag, &$text, $re) {
	{
		$f = $self->getFileUrl($tag, haquery_base_HaqDefines::$folders->support . "/" . $re->matched(1));
		return haquery_server_HaqTemplates_2($»this, $f, $files, $re, $reSupportFileUrl, $self, $tag, $text);
	}
}
function haquery_server_HaqTemplates_2(&$»this, &$f, &$files, &$re, &$reSupportFileUrl, &$self, &$tag, &$text) {
	if($f !== null) {
		return "/" . $f;
	} else {
		return $re->matched(0);
	}
}
