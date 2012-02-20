package haquery.server;

import haquery.server.HaqDefines;
import haquery.server.HaqComponent;
import haquery.server.HaqXml;

#if php
import php.FileSystem;
import php.io.File;
import php.Lessc;
#elseif neko
import neko.FileSystem;
import neko.io.File;
#end

using haquery.StringTools;

class HaqTemplateParser extends haquery.base.HaqTemplateParser
{
	public function new(fullTag:String)
	{
		super(fullTag);
	}
	
	override function getShortClassName() : String
	{
		return "Server";
	}
	
	override function getConfig() : HaqTemplateConfig
	{
		var pathParts = fullTag.split(".");
		pathParts.unshift("");
		
		var r = { extend : null, imports : new Array<String>() };
		
		var basePath = ".";
		for (pathPart in pathParts)
		{
			basePath += pathPart + '/';
			var c = parseConfig(getFullPath(basePath + "config.xml"));
			if (c != null)
			{
				r.extend = c.extend;
				r.imports = c.imports.concat(r.imports);
			}
		}
		
		return r;
	}
	
	function parseConfig(path:String) : HaqTemplateConfig
	{
		if (path != null && FileSystem.exists(path))
		{
			var r = { extend:null, imports:new Array<String>() };
			var xml = new HaqXml(File.getContent(path));
			
			var extendNodes = xml.find(">config>extend>component");
			if (extendNodes.length > 0)
			{
				if (extendNodes[0].hasAttribute("package"))
				{
					r.extend = extendNodes[0].getAttribute("package");
				}
			}
			
			var importComponentNodes = xml.find(">config>imports>components");
			for (importComponentNode in importComponentNodes)
			{
				if (importComponentNode.hasAttribute("package"))
				{
					r.imports.push(importComponentNode.getAttribute("package"));
				}
			}
			
			return r;
		}
		return null;
	}
	
	public function getSupportFilePath(fileName:String) : String
	{
		var path = getFullPath(fullTag.replace('.', '/') + '/' + HaqDefines.folders.support + '/' + fileName);
		if (path != null)
		{
			return path;
		}
		
		if (config.extend != null)
		{
			return getParentParser().getSupportFilePath(fileName);
		}
		
		return null;
	}
	
	public function getExtend() : String
	{
		return config.extend;
	}
	
	public function getDocAndCss() : { doc:HaqXml, css:String }
	{
        var text = getDocText();
		
		var reSupportFileUrl = new EReg("~/([-_/\\.a-zA-Z0-9]*)", "");
        text = reSupportFileUrl.customReplace(text, function(re)
        {
            var f = getSupportFilePath(re.matched(1));
            return f != null ? '/' + f : re.matched(0);
        });

		var doc = new HaqXml(text);
        
		resolvePlaceHolders(doc);
        
		var css = '';
		var i = 0; 
		while (i < doc.children.length)
		{
			var node : HaqXmlNodeElement = doc.children[i];
			if (node.name == 'style' && !node.hasAttribute('id'))
			{
				if (node.getAttribute('type') == "text/less")
				{
					#if php
					css += globalizeCssClassNames(new Lessc().parse(node.innerHTML));
					#else
					css += "\n// Lessc supported for the php target only.\n\n";
					#end
				}
				else
				{
					css += globalizeCssClassNames(node.innerHTML);
				}
				
				node.remove();
				i--;
			}
			i++;
		}
		
		return { doc:doc, css:css };
	}
	
	function getDocText() : String
	{
		var text = "";
		
		if (config.extend != null && config.extend != "" )
		{
			text += getParentParser().getDocText();
		}
		
		var path = getFullPath(fullTag.replace(".", "/") + "/template.html");
		if (path != null)
		{
			text += File.getContent(path);
		}
		
		return text;
	}
	
	function resolvePlaceHolders(doc:HaqXml)
	{
        var placeholders = doc.find('haq:placeholder');
        var contents = doc.find('>haq:content');
        for (ph in placeholders)
        {
            var content : HaqXmlNodeElement = null;
            for (c in contents) 
            {
                if (c.getAttribute('id') == ph.getAttribute('id'))
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
	
	function globalizeCssClassNames(text:String) : String
	{
		var blocks = new EReg("(?:[/][*].*?[*][/])|(?:[{].*?[}])|([^{]+)|(?:[{])", "s");
		var r = "";
		while (blocks.match(text))
		{
			if (blocks.matched(1) != null)
			{
				r += blocks.matched(0).replace(".", "." + (fullTag != "" ? fullTag.replace(".", "_") + HaqDefines.DELIMITER : ""));
			}
			else
			{
				r += blocks.matched(0);
			}
			text = text.substr(blocks.matchedPos().pos + blocks.matchedPos().len);
		}
		return r;
	}
	
	/**
	 * May be overriten.
	 */
	function getFullPath(path:String) : String
	{
		return FileSystem.exists(path) ? path : null;
	}
	
	public function getServerHandlers(className:String=null) : Hash<Array<String>>
	{
        Lib.profiler.begin('parseServerHandlers');
			var serverMethods = [ 'click','change' ];   // server events
            var serverHandlers : Hash<Array<String>> = new Hash<Array<String>>();
            var tempObj = Type.createEmptyInstance(Type.resolveClass(className != null ? className : getClassName()));
            for (field in Reflect.fields(tempObj))
            {
                if (Reflect.isFunction(Reflect.field(tempObj, field)))
                {
                    var parts = field.split('_');
                    if (parts.length == 2 && Lambda.has(serverMethods, parts[1]))
                    {
                        var nodeID = parts[0];
                        var method = parts[1];
                        if (!serverHandlers.exists(nodeID))
						{
							serverHandlers.set(nodeID, new Array<String>());
						}
                        serverHandlers.get(nodeID).push(method);
                    }
                }
            }
        Lib.profiler.end();
		
		return serverHandlers;
	}
}