<?php

class TrmGenerator {
	public function __construct(){}
	static function makeForComponents($componentsPackage) {
		$GLOBALS['%s']->push("TrmGenerator::makeForComponents");
		$製pos = $GLOBALS['%s']->length;
		$_g = 0; $_g1 = TrmTools::getClassPaths();
		while($_g < $_g1->length) {
			$classPath = $_g1[$_g];
			++$_g;
			$basePath = rtrim(str_replace("\\", "/", $classPath), "/") . "/";
			$path = $basePath . str_replace(".", "/", $componentsPackage);
			if(is_dir($path)) {
				TrmGenerator::makeForComponentsFolder($componentsPackage);
			}
			unset($path,$classPath,$basePath);
		}
		$GLOBALS['%s']->pop();
	}
	static function makeForComponentsFolder($componentsPackage) {
		$GLOBALS['%s']->push("TrmGenerator::makeForComponentsFolder");
		$製pos = $GLOBALS['%s']->length;
		haxe_Log::trace("TrmGenerator.makeForComponentsFolder('" . $componentsPackage . "')", _hx_anonymous(array("fileName" => "TrmGenerator.hx", "lineNumber" => 28, "className" => "TrmGenerator", "methodName" => "makeForComponentsFolder")));
		$path = TrmGenerator::findFile(str_replace(".", "/", $componentsPackage));
		haxe_Log::trace("readDirectory " . $path, _hx_anonymous(array("fileName" => "TrmGenerator.hx", "lineNumber" => 31, "className" => "TrmGenerator", "methodName" => "makeForComponentsFolder")));
		{
			$_g = 0; $_g1 = php_FileSystem::readDirectory($path);
			while($_g < $_g1->length) {
				$componentName = $_g1[$_g];
				++$_g;
				if(is_dir($path . "/" . $componentName)) {
					TrmGenerator::makeForComponent($componentsPackage, $componentName);
				}
				unset($componentName);
			}
		}
		$GLOBALS['%s']->pop();
	}
	static function makeForComponent($componentsPackage, $componentName) {
		$GLOBALS['%s']->push("TrmGenerator::makeForComponent");
		$製pos = $GLOBALS['%s']->length;
		haxe_Log::trace("TrmGenerator.makeForComponent('" . $componentsPackage . "', '" . $componentName . "')", _hx_anonymous(array("fileName" => "TrmGenerator.hx", "lineNumber" => 43, "className" => "TrmGenerator", "methodName" => "makeForComponent")));
		$componentData = TrmGenerator::getComponentData($componentsPackage, $componentName);
		$haxeClass = new TrmHaxeClass($componentsPackage . "." . $componentName . ".Template", $componentData->superClass);
		$haxeClass->addVar(TrmTools::createVar("component", "#if php haquery.server.HaqComponent #else haquery.client.HaqComponent #end", null), true, null);
		$haxeClass->addMethod("new", new _hx_array(array(TrmTools::createVar("component", "#if php haquery.server.HaqComponent #else haquery.client.HaqComponent #end", null))), "Void", "this.component = component;", null, null);
		php_io_File::putContent(TrmGenerator::findFile(str_replace(".", "/", $componentsPackage) . "/" . $componentName) . "/Template.hx", $haxeClass->toString());
		$GLOBALS['%s']->pop();
	}
	static function findFile($relativePath) {
		$GLOBALS['%s']->push("TrmGenerator::findFile");
		$製pos = $GLOBALS['%s']->length;
		$classPaths = TrmTools::getClassPaths();
		$i = $classPaths->length - 1;
		while($i >= 0) {
			if(file_exists($classPaths[$i] . $relativePath)) {
				$裨mp = $classPaths[$i] . $relativePath;
				$GLOBALS['%s']->pop();
				return $裨mp;
				unset($裨mp);
			}
			$i--;
		}
		{
			$GLOBALS['%s']->pop();
			return null;
		}
		$GLOBALS['%s']->pop();
	}
	static function getComponentData($componentsPackage, $componentName) {
		$GLOBALS['%s']->push("TrmGenerator::getComponentData");
		$製pos = $GLOBALS['%s']->length;
		$templateSuperClassPath = TrmGenerator::findFile(str_replace(".", "/", $componentsPackage) . $componentName . "/Template.hx");
		if($templateSuperClassPath !== null) {
			$裨mp = _hx_anonymous(array("templateText" => "", "superClass" => $componentsPackage . "." . $componentName));
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$templatePath = TrmGenerator::findFile(str_replace(".", "/", $componentsPackage) . $componentName . "/template.html");
		$templateText = (($templatePath !== null) ? php_io_File::getContent($templatePath) : "");
		$config = haquery_server_HaqConfig::getComponentsConfig(TrmTools::getClassPaths(), $componentsPackage);
		if($config->extendsPackage !== null && $config->extendsPackage !== "") {
			$superTemplateData = TrmGenerator::getComponentData($config->extendsPackage, $componentName);
			{
				$裨mp = _hx_anonymous(array("templateText" => $superTemplateData->templateText . $templateText, "superClass" => $superTemplateData->superClass));
				$GLOBALS['%s']->pop();
				return $裨mp;
			}
		}
		{
			$裨mp = _hx_anonymous(array("templateText" => $templateText, "superClass" => null));
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'TrmGenerator'; }
}
