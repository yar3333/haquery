package haquery.server;

import haquery.server.HaqComponent;
import haquery.server.HaqTemplate;
import haxe.Serializer;
import haquery.server.Lib;
import haquery.server.io.File;
import haxe.htmlparser.HtmlNodeElement;
import haquery.server.FileSystem;

using haquery.StringTools;
using haquery.HashTools;

class HaqTemplateManager extends haquery.base.HaqTemplateManager<HaqTemplate>
{
	static inline var MIN_DATE = new Date(2000, 0, 0, 0, 0, 0);
	
	var lastMods : Hash<Date>;
	
	var registeredScripts : Array<String>;
	var registeredStyles : Array<String>;
	
	public function new()
	{
		super();
		
		lastMods = new Hash<Date>();
		
		registeredScripts = [];
		registeredStyles = [];
		
		fillTemplates();
	}
	
	override function newTemplate(fullTag:String) : HaqTemplate
	{
		var templatesCacheDir = HaqDefines.folders.temp + "/templates/";
		
		var templateCachePath = templatesCacheDir + fullTag + ".dat";
		
		if (!FileSystem.exists(templateCachePath) || lastMods.get(fullTag).getTime() > FileSystem.stat(templateCachePath).mtime.getTime())
		{
			if (!FileSystem.exists(HaqDefines.folders.temp))
			{
				FileSystem.createDirectory(HaqDefines.folders.temp);
			}
			
			if (!FileSystem.exists(templatesCacheDir))
			{
				FileSystem.createDirectory(templatesCacheDir);
			}
			
			var template = new HaqTemplate(fullTag); 
			File.putContent(templateCachePath, template.serialize());
			return template;
		}
		else
		{
			Lib.profiler.begin("newTemplate");
			if (Lib.config.isTraceComponent)
			{
				trace("Unserialize template '" + fullTag + "'");
			}
			var template = HaqTemplate.unserialize(File.getContent(templateCachePath));
			Lib.profiler.end();
			return template;
		}
	}
	
	function fillTemplates()
	{
		var globalLastMod = MIN_DATE;
		for (fullTagAndLastMod in File.getContent("haquery/server/templates.dat").split("\n"))
		{
			var ft_lm = fullTagAndLastMod.split("\t");
			
			var fullTag = ft_lm[0];
			var lastMod = Date.fromTime(Std.parseInt(ft_lm[1]) * 10000.0);
			
			templates.set(fullTag, null);
			lastMods.set(fullTag, lastMod);
			
			if (lastMod.getTime() > globalLastMod.getTime())
			{
				globalLastMod = lastMod;
			}
		}
		
		var templatesCacheClientFilePath = HaqDefines.folders.temp + "/templates-cache-client.js";
		if (!FileSystem.exists(templatesCacheClientFilePath) || globalLastMod.getTime() > FileSystem.stat(templatesCacheClientFilePath).mtime.getTime())
		{
			if (!FileSystem.exists(HaqDefines.folders.temp))
			{
				FileSystem.createDirectory(HaqDefines.folders.temp);
			}
			trace("HAQUERY update client js file");
			File.putContent(templatesCacheClientFilePath, getStaticClientCode());
		}
		registerScript(null, "/" + templatesCacheClientFilePath);
		
		var templatesCacheStyleFilePath = HaqDefines.folders.temp + "/templates-cache-client.css";
		if (!FileSystem.exists(templatesCacheStyleFilePath) || globalLastMod.getTime() > FileSystem.stat(templatesCacheStyleFilePath).mtime.getTime())
		{
			if (!FileSystem.exists(HaqDefines.folders.temp))
			{
				FileSystem.createDirectory(HaqDefines.folders.temp);
			}
			trace("HAQUERY update css styles file");
			File.putContent(templatesCacheStyleFilePath, getStaticStyles());
		}
		registerStyle(null, "/" + templatesCacheStyleFilePath);
	}
	
	public function createPage(pageFullTag:String, attr:Hash<String>)
	{
        var template = get(pageFullTag);
		Lib.assert(template != null, "HAQUERY ERROR could't find page '" + pageFullTag + "'.");
		newComponent(template, null, '', attr, null, false);
	}
	
	public function createComponent(parent:HaqComponent, tag:String, id:String, attr:Hash<String>, parentNode:HtmlNodeElement, isCustomRender:Bool) : HaqComponent
	{
        var template = Lib.config.templateSelector.findTemplateToInstance(this, parent, tag);
		Lib.assert(template != null, "HAQUERY ERROR could't find component '" + tag + "' for parent '" + parent.fullTag + "'.");
		return newComponent(template, parent, id, attr, parentNode, isCustomRender);
	}
	
	function newComponent(template:HaqTemplate, parent:HaqComponent, id:String, attr:Hash<String>, parentNode:HtmlNodeElement, isCustomRender:Bool) : HaqComponent
	{
        Lib.profiler.begin('newComponent');
            var r : HaqComponent = Type.createInstance(Type.resolveClass(template.serverClassName), []);
			if (parent == null)
			{
				HaqSystem.page = cast r;
			}
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
			var template = get(fullTag);
			Lib.assert(template != null, "Template '" + fullTag + "' not found.");
			url = '/' + template.getSupportFilePath(url);
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
		return registeredStyles;
	}
	
	public function getRegisteredScripts() : Array<String>
	{
		return registeredScripts;
	}
	
	public function createDocComponents(parent:HaqComponent, baseNode:HtmlNodeElement, isCustomRender:Bool) : Array<HaqComponent>
    {
		var r = [];
		
		for (node in baseNode.children)
        {
			Lib.assert(node.name != 'haq:placeholder');
			Lib.assert(node.name != 'haq:content');
            
            if (node.name.startsWith('haq:'))
            {
				var tag = node.name.substr('haq:'.length).replace("-", ".");
				r.push(createComponent(parent, tag, node.getAttribute('id'), node.getAttributesAssoc(), node, isCustomRender));
            }
			else
			{
				r = r.concat(createDocComponents(parent, node, isCustomRender));
			}
        }
		
		return r;
    }
	
	function fillTagIDs(component:HaqComponent, destTagIDs:Hash<Array<String>>) : Hash<Array<String>>
	{
		if (component.visible)
		{
			if (!destTagIDs.exists(component.fullTag))
			{
				destTagIDs.set(component.fullTag, []);
			}
			destTagIDs.get(component.fullTag).push(component.fullID);
			
			for (child in component.components)
			{
				fillTagIDs(child, destTagIDs);
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
		
		s += "haquery.client.HaqInternals.sharedStorage = haxe.Unserializer.run(\"" + Serializer.run(sharedStorage) + "\");\n";
			  
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
	
	function getStaticStyles() : String
	{
		var text = "";
		for (fullTag in templates.keys())
		{
			var template = get(fullTag);
			if (template.css.length > 0)
			{
				text += "/" + "* " + fullTag + "*" + "/\n" + template.css + "\n\n";
			}
		}
		return text;
	}
}
