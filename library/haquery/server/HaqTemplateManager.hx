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
		
		var templatesCacheClientFilePath = HaqDefines.folders.temp + "/templates-cache-client.js";
		if (!Lib.config.isCacheTemplates || !FileSystem.exists(templatesCacheClientFilePath))
		{
			File.putContent(templatesCacheClientFilePath, getStaticClientCode());
		}
		registerScript(null, "/" + templatesCacheClientFilePath);
	}
	
	override function fillTemplates()
	{
		if (!FileSystem.exists(HaqDefines.folders.temp))
		{
			FileSystem.createDirectory(HaqDefines.folders.temp);
		}
		
		var templatesCacheServerFilePath = HaqDefines.folders.temp + "/templates-cache-server.dat";
		if (!Lib.config.isCacheTemplates || !FileSystem.exists(templatesCacheServerFilePath))
		{
			fillTemplatesBySearch(HaqDefines.folders.pages);
			
			if (Lib.config.isCacheTemplates)
			{
				var ser = new Serializer();
				ser.useCache = true;
				ser.serialize(templates);
				File.putContent(templatesCacheServerFilePath, ser.toString());
			}
		}
		else
		{
			templates = Unserializer.run(templatesCacheServerFilePath);
		}
	}
	
	override function parseTemplate(fullTag:String) : HaqTemplate
	{
		return new HaqTemplate(fullTag);
	}
	
	public function createPage(pageFullTag:String, attr:Hash<String>) : HaqPage
	{
		var template = new HaqTemplate(pageFullTag);
        return cast newComponent(pageFullTag, null, template.serverClassName, '', template.doc, attr, null);
	}
	
	public function createComponent(parent:HaqComponent, tag:String, id:String, attr:Hash<String>, parentNode:HaqXmlNodeElement) : HaqComponent
	{
		var template = findTemplate(parent.fullTag, tag);
		return newComponent(template.fullTag, parent, template.serverClassName, id, template.doc, attr, parentNode);
	}
	
	function newComponent(fulltag:String, parent:HaqComponent, className:String, id:String, doc:HaqXml, attr:Hash<String>, parentNode:HaqXmlNodeElement) : HaqComponent
	{
        Lib.profiler.begin('newComponent');
            var r : HaqComponent = Type.createInstance(Type.resolveClass(className), []);
            r.construct(this, fulltag, parent, id, doc, attr, parentNode);
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
			url = '/' + templates.get(fullTag).getSupportFilePath(url);
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
	
	function generatePackageCssFile(pack:String, fullTags:Array<String>, forceUpdate = false) : String
	{
		var path = HaqDefines.folders.temp + '/styles/' + pack + '.css';
		
		var text = "";
		for (fullTag in fullTags)
		{
			var template = templates.get(fullTag);
			text += "/* " + fullTag + "*/\n" + template.css + "\n\n";
		}
		
		File.putContent(path, text);
		
		return path;
	}
	
	public function getRegisteredStyles() : Array<String>
	{
		var packageStyles = [];
		var usedPackages = getPackages();
		for (pack in usedPackages.keys())
		{
			packageStyles.push(generatePackageCssFile(pack, usedPackages.get(pack)));
		}
		return packageStyles.concat(registeredStyles);
	}
	
	public function getRegisteredScripts() : Array<String>
	{
		return registeredScripts;
	}
	
	/**
	 * 
	 * @return package => [ fullTag0, fullTag1, ... ]
	 */
	function getPackages() : Hash<Array<String>>
	{
		var r = new Hash<Array<String>>();
		for (fullTag in templates.keys())
		{
			var pack = getPackageByFullTag(fullTag);
			if (!r.exists(pack))
			{
				r.set(pack, []);
			}
			r.get(pack).push(fullTag);
		}
		return r;
	}
	
	public function createChildComponents(parent:HaqComponent, baseNode:HaqXmlNodeElement)
    {
		for (node in baseNode.children)
        {
            trace("Create name = " + node.name);
			Lib.assert(node.name != 'haq:placeholder');
			Lib.assert(node.name != 'haq:content');
            
            createChildComponents(parent, node);
            
            if (node.name.startsWith('haq:'))
            {
				node.component = createComponent(parent, node.name.substr('haq:'.length), node.getAttribute('id'), node.getAttributesAssoc(), node);
            }
        }
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
		}
		
		for (subCom in com.components)
		{
			fillTagIDs(subCom, destTagIDs);
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
					var t = templates.get(tag);
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
