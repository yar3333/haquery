package haquery.server;

import sys.io.File;
import haquery.Exception;
import haxe.htmlparser.HtmlDocument;
import haxe.htmlparser.HtmlNodeElement;
import haquery.common.HaqDefines;
import haquery.common.HaqTemplateExceptions;
import haquery.server.HaqCssGlobalizer;
import haquery.server.HaqComponent;
import haquery.server.FileSystem;
import haquery.server.HaqTemplateConfig;
import haquery.server.HaqTemplateParser;
using haquery.StringTools;

class HaqTemplateParser extends haquery.base.HaqTemplateParser<HaqTemplateConfig>
{
	static var reSupportUrl = new EReg("~/([-_/\\.a-zA-Z0-9]*)", "");
	
	var childFullTags : Array<String>;
	
	public function new(fullTag:String, childFullTags:Array<String>)
	{
		super(fullTag);
		
		if (Lambda.has(childFullTags, fullTag))
		{
			throw new HaqTemplateRecursiveExtendsException(childFullTags.join(" - ") + " - " + fullTag);
		}
		
		this.childFullTags = childFullTags;
	}
	
	override function isTemplateExist(fullTag:String) : Bool
	{
		var localPath = fullTag.replace(".", "/");
		if (getFullPath(localPath + '/template.html') != null || Type.resolveClass(fullTag + ".Server") != null)
		{
			return true;
		}
		return false;
	}
	
	override function getParentParser() : HaqTemplateParser
	{
		if (config.extend == null || config.extend == "") return null; 
		try 
		{
			return new HaqTemplateParser(config.extend, childFullTags.concat([fullTag]));
		}
		catch (e:HaqTemplateNotFoundException)
		{
			throw new HaqTemplateNotFoundCriticalException(e.toString());
		}
	}
	
	override function getShortClassName() : String
	{
		return "Server";
	}
	
	override function getConfig() : HaqTemplateConfig
	{
		var pathParts = fullTag.split(".");
		pathParts.unshift("");
		
		var r = new HaqTemplateConfig(null, null);
		
		var basePath = ".";
		for (pathPart in pathParts)
		{
			basePath += pathPart + "/";
			var configPath = getFullPath(basePath + "config.xml");
			if (configPath != null)
			{
				try
				{
					r = new HaqTemplateConfig(r, new HtmlDocument(File.getContent(configPath)));
				}

				catch (e:HaqTemplateConfigParseException)
				{
					throw new HaqTemplateConfigParseException(e.message + " Check '" + configPath + "'.");
				}
			}
		}
		
		if (r.extend == fullTag)
		{
			r.noExtend();
		}
		
		return r;
	}
	
	public function getSupportFilePath(fileName:String) : String
	{
		var path = getFullPath(fullTag.replace('.', '/') + '/' + HaqDefines.folders.support + '/' + fileName);
		if (path != null)
		{
			return path;
		}
		
		var parentParser = getParentParser();
		if (parentParser != null)
		{
			return parentParser.getSupportFilePath(fileName);
		}
		
		return null;
	}
	
	public function getExtend() : String
	{
		return config.extend;
	}
	
	public function getDocAndCss() : { doc:HtmlDocument, css:String }
	{
		var doc = new HtmlDocument();
		var css = "";
		
		var parsers = [ this ];
		var p = this;
		while ((p = p.getParentParser()) != null)
		{
			parsers.push(p);
		}
		
		while (parsers.length > 0)
		{
			var p = parsers.pop();
			var raw = p.getRawDocAndCss();
			for (node in raw.doc.nodes)
			{
				doc.addChild(node);
			}
			css += raw.css;
		}
		
		resolveSupportUrls(doc);
		resolvePlaceHolders(doc);
		
		var cssGlobalizer = new HaqCssGlobalizer(fullTag);
		
		cssGlobalizer.doc(doc);
		css = cssGlobalizer.styles(css);
		
		return { doc:doc, css:css };
	}
	
	function getRawDocAndCss() : { doc:HtmlDocument, css:String }
	{
		var path = getFullPath(fullTag.replace(".", "/") + "/template.html");
		if (path != null)
		{
			var text = File.getContent(path);
			var doc = new HtmlDocument(text);
			
			var css = '';
			var i = 0; 
			while (i < doc.children.length)
			{
				var node = doc.children[i];
				if (node.name == "style" && !node.hasAttribute("id"))
				{
					Lib.assert(node.getAttribute("type") != "text/less", "Less compiler is no more supported.");
					css += node.innerHTML;
					node.remove();
					i--;
				}
				i++;
			}
			
			return { doc:doc, css:css };
		}
		
		print("WARNING: File '" + (fullTag.replace(".", "/") + "/template.html") + "' not found.");
		
		return { doc:new HtmlDocument(), css:"" };
	}
	
	function resolveSupportUrls(doc:HtmlNodeElement)
	{
		for (node in doc.children)
		{
			var attrs = node.getAttributesAssoc();
			for (name in attrs.keys())
			{
				if (reSupportUrl.match(name))
				{
					var value = reSupportUrl.customReplace(attrs.get(name), function(re)
					{
						var f = getSupportFilePath(re.matched(1));
						return f != null ? "/" + f : re.matched(0);
					});
					node.setAttribute(name, value);
				}
			}
		}
	}
	
	function resolvePlaceHolders(doc:HtmlDocument)
	{
        var placeholders = doc.find("haq:placeholder");
        
		var contents = doc.find(">haq:content");
		contents.reverse();
		
        for (ph in placeholders)
        {
            var content : HtmlNodeElement = null;
            for (c in contents) 
            {
                if (c.getAttribute("id") == ph.getAttribute("id"))
                {
                    content = c;
                    break;
                }
            }
            if (content != null)
			{
				ph.parent.replaceChildWithInner(ph, content);
			}
            else
			{
				ph.parent.replaceChildWithInner(ph, ph);
			}
        }
		
		for (c in doc.find('>haq:content'))
		{
			c.remove();
		}
	}
	
	/**
	 * May be overriten.
	 */
	function getFullPath(path:String) : String
	{
		return FileSystem.exists(path.rtrim("/")) ? path : null;
	}
	
	public function getServerHandlers(className:String=null) : Hash<Array<String>>
	{
		var serverMethods = [ 'click', 'change' ];   // server events
		var serverHandlers = new Hash<Array<String>>();
		var haxeClass = Type.resolveClass(className != null ? className : getClassName());
		var obj = Type.createEmptyInstance(haxeClass);
		for (field in Type.getInstanceFields(haxeClass))
		{
			if (Reflect.isFunction(Reflect.field(obj, field)))
			{
				var n = field.lastIndexOf("_");
				if (n > 0 && Lambda.has(serverMethods, field.substr(n + 1)))
				{
					var nodeID = field.substr(0, n);
					var method = field.substr(n + 1);
					if (!serverHandlers.exists(nodeID))
					{
						serverHandlers.set(nodeID, new Array<String>());
					}
					serverHandlers.get(nodeID).push(method);
				}
			}
		}
		return serverHandlers;
	}
	
	function print(s:String) {}
}