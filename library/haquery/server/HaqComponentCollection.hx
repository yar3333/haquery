package haquery.server;

import haquery.server.HaqTemplate;
import haquery.server.template_parsers.ComponentTemplateParser;
import haquery.server.HaqXml;
import php.FileSystem;
import php.io.File;
import php.NativeArray;

class HaqComponentCollection extends haquery.base.HaqComponentCollection
{
	public function new(name:String) 
	{
		super(name, getImports(name), getTemplates(name));
	}
	
	function getImports(name:String) : Array<HaqComponentCollection>
	{
		if (name == null || name == '')
		{
			return [];
		}
		return parseImports(getFullPath(HaqDefines.folders.components + '/' + name + '/config.xml'));
	}
	
	function parseImports(configPath:String) : Array<HaqComponentCollection>
	{
		var r = new Array<HaqComponentCollection>();
		
		if (FileSystem.exists(configPath))
		{
			var xml = new HaqXml(File.getContent(configPath));
			var nodes = xml.find(">collection>import");
			for (node in nodes)
			{
				if (node.hasAttribute("collection"))
				{
					var collectionName = StringTools.trim(node.getAttribute("collection"));
					if (collectionName != "")
					{
						if (haquery.base.HaqComponentCollection.collections.exists(collectionName))
						{
							r.push(haquery.base.HaqComponentCollection.collections.get(collectionName));
						}
						else
						{
							var collection = new HaqComponentCollection(collectionName);
							r.push(collection);
							haquery.base.HaqComponentCollection.collections.set(collectionName, collection);
						}
					}
				}
			}
		}
		
		return r;
	}
	
	function getTemplates(name:String) : Hash<HaqTemplate>
	{
		if (name == null || name == '')
		{
			return new Hash<HaqTemplate>();
		}
		
		var r = new Hash<HaqTemplate>();
		
		var path = getFullPath(HaqDefines.folders.components + '/' + name);
		for (tag in FileSystem.readDirectory(path))
		{
			if (FileSystem.isDirectory(path + '/' + tag))
			{
				r.set(tag, parseTemplate(name, tag));
			}
		}
		
		return r;
	}
	
	/**
	 * May be overriten.
	 */
	function parseTemplate(name:String, tag:String)
	{
		return new HaqTemplate(new ComponentTemplateParser(name, tag));
	}
	
	/**
	 * May be overriten.
	 */
	function getFullPath(path:String)
	{
		return path;
	}
}