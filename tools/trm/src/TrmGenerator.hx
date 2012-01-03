package ;

import haquery.server.HaqConfig;
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
				makeForComponentsFolder(basePath, componentsPackage);
			}
		}
    }
	
	static public function makeForComponentsFolder(basePath:String, componentsPackage:String)
	{
		trace("TrmGenerator.makeForComponentsFolder");
		trace("basePath = " + basePath);
		trace("componentsPackage = " + componentsPackage);
		
		/*for (componentPath in FileSystem.readDirectory(basePath + componentsFolder))
		{
			if (FileSystem.isDirectory(basePath + componentPath))
			{
				var templatePath = basePath + componentPath + "template.html";
				if (FileSystem.exists(templatePath))
				{
					TrmClassGenerator.make(basePath, componentPath.rtrim("/").replace("/", "."));
				}
			}
		}*/
	}
}
