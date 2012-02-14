package haquery;

#if neko
import neko.FileSystem;
import neko.io.File;
#elseif php
import php.FileSystem;
import php.io.File;
#end

import haxe.xml.Fast;

using StringTools;

class CompileStageComponentTemplateParser
{
	var classPaths : Array<String>;
	var collection : String;
	var tag : String;
	
	public var config(default, null) : ComponentConfig;
	
	public function new(classPaths:Array<String>, collection:String, tag:String)
	{
		this.classPaths = classPaths;
		this.collection = collection;
		this.tag = tag;
		
		config = getConfig();
	}
	
	function getConfig() : ComponentConfig
	{
		var path = getFullPath(HaqDefines.folders.components + '/' + collection + '/' + tag + '/config.xml');
		
		var r = { extendsCollection : null };
		
		if (FileSystem.exists(path))
		{
			/*var xml = new HaqXml(File.getContent(path));
			var nativeNodes : NativeArray = xml.find(">component>extends");
			if (nativeNodes != null)
			{
				var nodes : Array<HaqXmlNodeElement> = cast Lib.toHaxeArray(nativeNodes);
				if (nodes.length > 0)
				{
					if (nodes[0].hasAttribute("collection"))
					{
						configCache.extendsCollection = nodes[0].getAttribute("collection");
					}
				}
			}*/
			
			var xml = Xml.parse(File.getContent(path));
			var fast = new Fast(xml.firstElement());
			if (fast.hasNode.resolve("extends"))
			{
				var extendsNode = fast.node.resolve("extends");
				if (extendsNode.has.collection)
				{
					r.extendsCollection = extendsNode.att.collection;
				}
			}
			
		}
		
		return r;
	}
	
	function getFullPath(path:String)
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
	
	function getClassName(className:String)
	{
		var className = HaqDefines.folders.components + "." + collection + "." + tag + "." + className;
		if (getFullPath(className.replace('.', '/') + ".hx") != null)
		{
			return className;
		}
		
		if (config.extendsCollection != null && config.extendsCollection != "")
		{
			return new CompileStageComponentTemplateParser(classPaths, config.extendsCollection, tag).getClassName(className);
		}
		
		return null;
	}
	
	public function getServerClassName()
	{
		var r = getClassName("Server");
		return r != null && r != "" ? r : "haquery.server.HaqComponent";
	}
	
	public function getClientClassName()
	{
		var r = getClassName("Client");
		return r != null && r != ""  ? r : "haquery.client.HaqComponent";
	}
}