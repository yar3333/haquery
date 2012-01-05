package ;

import haquery.server.HaqConfig;
import haquery.server.HaqTemplates;
import php.FileSystem;
import php.io.File;
import php.Lib;

using haquery.StringTools;

class TrmGenerator
{
	static public function makeForComponents(componentsPackage:String)
    {
		for (classPath in TrmTools.getClassPaths())
		{
			var basePath = classPath.replace("\\", "/").rtrim("/") + "/";
			var path = basePath + componentsPackage.replace(".", "/");
			if (FileSystem.isDirectory(path))
			{
				makeForComponentsFolder(componentsPackage);
			}
		}
    }
	
	static function makeForComponentsFolder(componentsPackage:String)
	{
		trace("TrmGenerator.makeForComponentsFolder('" + componentsPackage + "')");
		
		var path = findFile(componentsPackage.replace(".", "/"));
		trace("readDirectory " + path);
		for (componentName in FileSystem.readDirectory(path))
		{
			if (FileSystem.isDirectory(path + "/" + componentName))
			{
				makeForComponent(componentsPackage, componentName);
			}
		}
	}
	
	static function makeForComponent(componentsPackage:String, componentName:String)
	{
		trace("TrmGenerator.makeForComponent('" + componentsPackage + "', '" + componentName + "')");
		
		var componentData = getComponentData(componentsPackage, componentName);
		
		var haxeClass = new TrmHaxeClass(componentsPackage + "." + componentName + ".Template", componentData.superClass);
		
		haxeClass.addVar(TrmTools.createVar("component", "#if php haquery.server.HaqComponent #else haquery.client.HaqComponent #end"), true);
		
		haxeClass.addMethod(
			 "new"
			,[ TrmTools.createVar("component", "#if php haquery.server.HaqComponent #else haquery.client.HaqComponent #end") ]
			,"Void"
			,"this.component = component;"
		);
		
		File.putContent(findFile(componentsPackage.replace(".", "/") + "/" + componentName) + "/Template.hx", haxeClass.toString());
	}
	
	static function findFile(relativePath:String) : String
	{
		var classPaths = TrmTools.getClassPaths();
		var i = classPaths.length - 1;
		while (i >= 0)
		{
			if (FileSystem.exists(classPaths[i] + relativePath))
			{
				return classPaths[i] + relativePath;
			}
			i--;
		}
		return null;
	}
	
	static function getComponentData(componentsPackage:String, componentName:String) : { templateText:String, superClass:String }
	{
		var templateSuperClassPath = findFile(componentsPackage.replace(".", "/") + componentName + "/Template.hx");
		if (templateSuperClassPath != null)
		{
			return { templateText : "", superClass : componentsPackage + "." + componentName };
		}
		
		var templatePath = findFile(componentsPackage.replace(".", "/") + componentName + "/template.html");
		var templateText = templatePath != null ? File.getContent(templatePath) : "";
		
		var config = HaqConfig.getComponentsConfig(TrmTools.getClassPaths(), componentsPackage);
		if (config.extendsPackage != null && config.extendsPackage != "")
		{
			var superTemplateData = getComponentData(config.extendsPackage, componentName);
			return { templateText : superTemplateData.templateText + templateText, superClass : superTemplateData.superClass };
		}
		
		return { templateText : templateText, superClass : null };
	}
}
