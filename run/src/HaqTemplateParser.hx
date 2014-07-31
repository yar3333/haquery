package ;

import hant.Log;
import haquery.common.HaqDefines;
import haquery.common.HaqTemplateExceptions;
import haquery.server.HaqCssGlobalizer;
import htmlparser.HtmlDocument;
import htmlparser.HtmlNodeElement;
import stdlib.Exception;
import stdlib.FileSystem;
import sys.io.File;
using StringTools;

class HaqTemplateParser
{
	static var MIN_DATE = new Date(2000, 0, 0, 0, 0, 0);
	static var reSupportUrl = new EReg("~/([-_/\\.a-zA-Z0-9]*)", "g");
	
	static var configsCache = new Map<String, HtmlDocument>();
	
	var log : Log;
	var classPaths : Array<String>;
	var fullTag : String;
	var childFullTags : Array<String>;
	var basePage : String;
	var staticUrlPrefix : String;
	var substitutes : Array<{ from:EReg, to:String }>;
	
	var config : HaqTemplateConfig;
	
	public function new(log:Log, classPaths:Array<String>, fullTag:String, childFullTags:Array<String>, basePage:String, staticUrlPrefix:String, substitutes:Array<{ from:EReg, to:String }>)
	{
		if (Lambda.has(childFullTags, fullTag))
		{
			throw new HaqTemplateRecursiveExtendsException(childFullTags.join(" - ") + " - " + fullTag);
		}
		
		this.log = log;
		this.classPaths = classPaths;
		this.fullTag = fullTag;
		this.childFullTags = childFullTags;
		this.basePage = basePage;
		this.staticUrlPrefix = staticUrlPrefix;
		this.substitutes = substitutes;
		
		var folder = fullTag.replace(".", "/") + "/";
		if (getFullPath(folder + "template.html") == null && getFullPath(folder + "Server.hx") == null && getFullPath(folder + "Client.hx") == null)
		{
			throw new HaqTemplateNotFoundException(fullTag);
		}
		
		config = getConfig();
	}
	
	function getParentParser() : HaqTemplateParser
	{
		if (config.extend == "") return null; 
		try 
		{
			return new HaqTemplateParser(log, classPaths, config.extend, childFullTags.concat([fullTag]), basePage, staticUrlPrefix, substitutes);
		}
		catch (e:HaqTemplateNotFoundException)
		{
			throw new HaqTemplateNotFoundCriticalException(e.toString());
		}
	}
	
	function getFullPath(path:String, noSrcPrefix=false) : String
	{
		if (path.startsWith("./"))
		{
			path = path.substr(2);
		}
		
		var i = classPaths.length - 1;
		while (i >= 0)
		{
			var fullPath = classPaths[i] + path;
			if (FileSystem.exists(fullPath))
			{
				return !noSrcPrefix ? fullPath : fullPath.substr(classPaths[i].length);
			}
			i--;
		}
		return null;
	}
	
	function getLocalClassName(shortClassName:String) : String
	{
		var fullClassName = fullTag + "." + shortClassName;
		if (getFullPath(fullClassName.replace('.', '/') + ".hx") != null)
		{
			return fullClassName;
		}
		return null;
	}
	
	function getGlobalClassName(shortClassName:String)
	{
		var localClassName = getLocalClassName(shortClassName);
		if (localClassName != null)
		{
			return localClassName;
		}
		
		var parentParser = getParentParser();
		if (parentParser != null)
		{
			return parentParser.getGlobalClassName(shortClassName);
		}
		
		return null;
	}
	
	public function getServerClassName()
	{
		var r = getGlobalClassName("Server");
		return r != null && r != "" 
			? r 
			: (fullTag.startsWith("pages.") ? "haquery.server.HaqPage" : "haquery.server.HaqComponent");
	}
	
	public function getClientClassName()
	{
		var r = getGlobalClassName("Client");
		return r != null && r != ""  
			? r 
			: (fullTag.startsWith("pages.") ? "haquery.client.HaqPage" : "haquery.client.HaqComponent");
	}
	
	public function hasLocalServerClass() : Bool
	{
		return getLocalClassName("Server") != null;
	}
	
	public function hasLocalClientClass() : Bool
	{
		return getLocalClassName("Client") != null;
	}
	
	public function getGenFolder() : String
	{
		return "gen/" + fullTag.replace('.', '/') + "/";
	}
	
	function getConfig() : HaqTemplateConfig
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
				var doc : HtmlDocument;
				
				if (configsCache.exists(configPath))
				{
					doc = configsCache.get(configPath);
				}
				else
				{
					doc = new HtmlDocument(File.getContent(configPath));
					configsCache.set(configPath, doc);
				}
				
				try
				{
					r = new HaqTemplateConfig(r, doc);
				}
				catch (e:HaqTemplateConfigParseException)
				{
					throw new HaqTemplateConfigParseException(e.message + " Check '" + configPath + "'.");
				}
			}
		}
		
		if (r.extend == fullTag)
		{
			r.extend = "";
		}
		
		return r;
	}
	
	public function getRequires() : Array<String>
	{
		return config.requires;
	}
	
	public function getBaseServerClass() : String
	{
		var parentParser = getParentParser();
		return parentParser != null 
			? parentParser.getServerClassName() 
			: (fullTag.startsWith("pages.") ? "haquery.server.HaqPage" : "haquery.server.HaqComponent");
	}	
	
	public function getBaseClientClass() : String
	{
		var parentParser = getParentParser();
		return parentParser != null 
			? parentParser.getClientClassName() 
			: (fullTag.startsWith("pages.") ? "haquery.client.HaqPage" : "haquery.client.HaqComponent");
	}
	
	function setDocComponentsParent(doc:HtmlNodeElement)
	{
		for (node in doc.children)
		{
			if (node.name.startsWith("haq:"))
			{
				node.setAttribute("__parent", fullTag);
			}
			setDocComponentsParent(node);
		}
	}
	
	public function getImports()
	{
		return config.imports;
	}
	
	public function getDocAndCss() : { doc:HtmlDocument, cssBlocks:Array<String> }
	{
		var parsers : Array<HaqTemplateParser> = [ this ];
		var p = this;
		while ((p = p.getParentParser()) != null)
		{
			parsers.push(p);
		}
		
		var cssGlobalizer = new HaqCssGlobalizer(fullTag);
		
		var cssBlocks : Array<String> = [];
		
		var doc = new HtmlDocument();
		while (parsers.length > 0)
		{
			var p = parsers.pop();
			
			var rawDoc = p.getRawDoc();
			for (node in rawDoc.nodes)
			{
				doc.addChild(node);
			}
			
			var rawCss = p.getRawCss();
			if (rawCss != null)
			{
				cssBlocks.push(cssGlobalizer.styles(rawCss));
			}
		}
		
		resolveSupportUrls(doc);
		resolvePlaceHolders(doc);
		
		var i = 0; 
		while (i < doc.children.length)
		{
			var node = doc.children[i];
			if (node.name == "style" && !node.hasAttribute("id"))
			{
				if (node.getAttribute("type") == "text/less")
				{
					throw new Exception("Less compiler is no more supported.");
				}
				cssBlocks.push(cssGlobalizer.styles(node.innerHTML));
				node.remove();
				i--;
			}
			i++;
		}
		
		
		cssGlobalizer.doc(doc);
		
		return { doc:doc, cssBlocks:cssBlocks };
	}
	
	function getRawDoc() : HtmlDocument
	{
		var path = getFullPath(fullTag.replace(".", "/") + "/template.html");
		var text = path != null ? File.getContent(path) : "";
		var doc = new HtmlDocument(applySubstitutes(text));
		setDocComponentsParent(doc);
		return doc;
	}
	
	function getRawCss() : String
	{
		var path = getFullPath(fullTag.replace(".", "/") + "/template.css");
		if (path == null) return null;
		return applySubstitutes(File.getContent(path));
	}
	
	function resolveSupportUrls(doc:HtmlNodeElement)
	{
		for (node in doc.children)
		{
			var attrs = node.getAttributesAssoc();
			for (name in attrs.keys())
			{
				var value = attrs.get(name);
				if (reSupportUrl.match(value))
				{
					value = reSupportUrl.map(value, function(re)
					{
						var f = getSupportFilePath(re.matched(1));
						return f != null ? staticUrlPrefix + "/" + f : re.matched(0);
					});
					node.setAttribute(name, value);
				}
			}
			
			if (node.name == "style")
			{
				node.setInnerText(reSupportUrl.map(node.innerHTML, function(re)
				{
					var f = getSupportFilePath(re.matched(1));
					return f != null ? staticUrlPrefix + "/" + f : re.matched(0);
				}));
			}
			else
			{
				resolveSupportUrls(node);
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
	
	public function getSupportFilePath(fileName:String) : String
	{
		var path = getFullPath(fullTag.replace('.', '/') + '/' + HaqDefines.folders.support + '/' + fileName, true);
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
	
	function applySubstitutes(s:String) : String
	{
		for (substitute in substitutes)
		{
			s = substitute.from.replace(s, substitute.to);
		}
		return s;
	}
}