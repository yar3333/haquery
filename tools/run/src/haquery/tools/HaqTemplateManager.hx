package haquery.tools;

import haquery.server.FileSystem;
import haquery.tools.HaqTemplate;

class HaqTemplateManager extends haquery.base.HaqTemplateManager<HaqTemplate>
{
	var classPaths : Array<String>;
	
	public function new(classPaths:Array<String>)
	{
		this.classPaths = classPaths;
		super();
	}
	
	override function parseTemplate(fullTag:String) : HaqTemplate
	{
		return new HaqTemplate(classPaths, fullTag);
	}
	
	override function getFullPath(path:String)
	{
		var i = classPaths.length - 1;
		while (i >= 0)
		{
			var fullPath = classPaths[i] + path;
			if (FileSystem.exists(fullPath))
			{
				return fullPath;
			}
			i--;
		}
		return null;
	}
}