package haquery.server;

import haxe.Serializer;
import haxe.Unserializer;

import haquery.server.HaqComponent;
import haquery.server.HaqTemplate;
import haquery.server.HaqXml;
import haquery.server.Lib;
import haquery.server.io.File;
import haquery.server.HaqTemplateParser;
import haquery.server.FileSystem;
import haquery.base.HaqTemplateParser.HaqTemplateNotFoundException;

using haquery.StringTools;
using haquery.HashTools;

class HaqTemplateManager extends haquery.base.HaqTemplateManager<HaqTemplate>
{
	var registeredScripts : Array<String>;
	var registeredStyles : Array<String>;
	
	public function new()
	{
		super();
		
		registeredScripts = [];
		registeredStyles = [];
		
		fillTemplates();
		
		var templatesCacheClientFilePath = HaqDefines.folders.temp + "/templates-cache-client.js";
		if (!Lib.config.useCache || !FileSystem.exists(templatesCacheClientFilePath))
		{
			File.putContent(templatesCacheClientFilePath, getStaticClientCode());
		}
		registerScript(null, "/" + templatesCacheClientFilePath);
	}
	
	override function newTemplate(fullTag:String) : HaqTemplate
	{
		return new HaqTemplate(fullTag); 
	}

	function fillTemplates()
	{
		if (!FileSystem.exists(HaqDefines.folders.temp))
		{
			FileSystem.createDirectory(HaqDefines.folders.temp);
		}
		
		var templatesCacheServerFilePath = HaqDefines.folders.temp + "/templates-cache-server.dat";
		if (!Lib.config.useCache || !FileSystem.exists(templatesCacheServerFilePath))
		{
			for (fullTag in File.getContent("haquery/server/templates.dat").split("\n"))
			{
				templates.set(fullTag, null);
			}
			
			if (Lib.config.useCache)
			{
				var ser = new Serializer();
				ser.useCache = true;
				ser.serialize(templates);
				File.putContent(templatesCacheServerFilePath, ser.toString());
			}
		}
		else
		{
			templates = Unserializer.run(File.getContent(templatesCacheServerFilePath));
		}
	}
	
	public function createPage(pageFullTag:String, attr:Hash<String>) : HaqPage
	{
        var template = get(pageFullTag);
		if (template == null)
		{
			throw "HAQUERY ERROR could't find page '" + pageFullTag + "'.";
		}
		return cast newComponent(template, null, '', attr, null, false);
	}
	
	public function createComponent(parent:HaqComponent, tag:String, id:String, attr:Hash<String>, parentNode:HaqXmlNodeElement, isCustomRender:Bool) : HaqComponent
	{
        var template = findTemplateDeep(parent, tag);
		if (template == null)
		{
			throw "HAQUERY ERROR could't find component '" + tag + "' for parent '" + parent.fullTag + "'.";
		}
		return newComponent(template, parent, id, attr, parentNode, isCustomRender);
	}
	
	function newComponent(template:HaqTemplate, parent:HaqComponent, id:String, attr:Hash<String>, parentNode:HaqXmlNodeElement, isCustomRender:Bool) : HaqComponent
	{
        Lib.profiler.begin('newComponent');
            var r : HaqComponent = Type.createInstance(Type.resolveClass(template.serverClassName), []);
			r.construct(this, template.fullTag, parent, id, template.getDocCopy(), attr, parentNode, isCustomRender);
        Lib.profiler.end();
		return r;
	}
	
	function getFullUrl(fullTag:String, url:String) : String
	{
		if (url.startsWith("~/"))
		{
			url = url.substr(2);
		}
		
		if (!url.startsWith("http://") && !url.startsWith("/") && !url.startsWith("<"))
		{
			url = '/' + get(fullTag).getSupportFilePath(url);
		}
		
		return url;
	}
	
	/**
	 * Tells HaQuery to load JS file from support component folder.
	 * @param	fullTag Component package name.
	 * @param	url Url to js file (global or related to support component folder).
	 */
    public function registerScript(fullTag:String, url:String) : Void
	{
		url = getFullUrl(fullTag, url);
		if (!Lambda.has(registeredScripts, url))
		{
			registeredScripts.push(url);
		}
	}
	
	/**
	 * Tells HaQuery to load CSS file from support component folder.
	 * @param	fullTag Component package name.
	 * @param	url Url to css file (global or related to support component folder).
	 */
	public function registerStyle(fullTag:String, url:String) : Void
	{
		url = getFullUrl(fullTag, url);
		if (!Lambda.has(registeredStyles, url))
		{
			registeredStyles.push(url);
		}
	}
	
	public function getRegisteredStyles() : Array<String>
	{
		return [ generateStylesFile() ].concat(registeredStyles);
	}
	
	function generateStylesFile() : String
	{
		var path = HaqDefines.folders.temp + '/templates-cache-client.css';
		
		if (!Lib.config.useCache || !FileSystem.exists(path))
		{
			if (!FileSystem.exists(HaqDefines.folders.temp))
			{
				FileSystem.createDirectory(HaqDefines.folders.temp);
			}
			
			var text = "";
			for (fullTag in templates.keys())
			{
				var template = get(fullTag);
				text += "/* " + fullTag + "*/\n" + template.css + "\n\n";
			}
			
			File.putContent(path, text);
		}
		
		return path;
	}
	
	public function getRegisteredScripts() : Array<String>
	{
		return registeredScripts;
	}
	
	public function createDocComponents(parent:HaqComponent, baseNode:HaqXmlNodeElement, isCustomRender:Bool) : Array<HaqComponent>
    {
		var r = [];
		
		for (node in baseNode.children)
        {
			Lib.assert(node.name != 'haq:placeholder');
			Lib.assert(node.name != 'haq:content');
            
            if (node.name.startsWith('haq:'))
            {
				r.push(createComponent(parent, node.name.substr('haq:'.length), node.getAttribute('id'), node.getAttributesAssoc(), node, isCustomRender));
            }
			else
			{
				r = r.concat(createDocComponents(parent, node, isCustomRender));
			}
        }
		
		return r;
    }
	
	function fillTagIDs(com:HaqComponent, destTagIDs:Hash<Array<String>>) : Hash<Array<String>>
	{
		if (com.visible)
		{
			if (!destTagIDs.exists(com.fullTag))
			{
				destTagIDs.set(com.fullTag, []);
			}
			destTagIDs.get(com.fullTag).push(com.fullID);
			
			for (subCom in com.components)
			{
				fillTagIDs(subCom, destTagIDs);
			}
		}
		
		return destTagIDs;
	}
	
	function array2json(a:Iterable<String>) : String
	{
		return "[" + Lambda.map(a, function(s) return "'" + s + "'").join(",") + "]";
	}
	
	public function getDynamicClientCode(page:HaqPage) : String
    {
		var tagIDs = fillTagIDs(page, new Hash<Array<String>>());
		
		var s = "haquery.client.HaqInternals.tagIDs = haquery.HashTools.hashify({\n"
		      + Lambda.map(tagIDs.keysIterable(), function(tag) {
					return "'" + tag + "':" + array2json(tagIDs.get(tag));
				}).join(",\n")
			  + "\n});\n";
		
		s += "haquery.client.Lib.run('" + page.fullTag + "');\n";

        return s;
    }
	
	function getStaticClientCode() : String
	{
		var s = "haquery.client.HaqInternals.templates = haquery.HashTools.hashify({\n"
		      + Lambda.map(templates.keysIterable(), function(tag) {
					var t = get(tag);
					return "'" + tag + "':"
						 + "{" 
							 + "config:" + array2json([t.extend].concat(t.imports)) 
							 + ", "
							 + "serverHandlers:haquery.HashTools.hashify({" 
								+ Lambda.map(t.serverHandlers.keysIterable(), function(elemID) {
									return "'" + elemID + "':" + array2json(t.serverHandlers.get(elemID));
								  }).join(",")
							 + "})"
						 + "}";
				}).join(",\n")
			  + "\n});\n";
		return s;
	}
}
