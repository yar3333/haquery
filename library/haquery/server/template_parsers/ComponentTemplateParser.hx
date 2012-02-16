package haquery.server.template_parsers;

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

class ComponentTemplateParser implements ITemplateParser
{
	var fullTag : String;
	var config : ComponentConfig;
	
	public function new(fullTag:String)
	{
		this.fullTag = fullTag;
		config = getConfig();
	}
	
	public function getClass() : Class<HaqComponent>
	{
		var className = fullTag + ".Server";
		var clas = Type.resolveClass(className);
		if (clas != null)
		{
			return cast clas;
		}
		
		if (config.extend != null)
		{
			return new ComponentTemplateParser(config.extend).getClass();
		}
		
		return getBaseClass();
	}
	
	/**
	 * May be overrided.
	 */
	function getBaseClass() : Class<HaqComponent>
	{
		return HaqComponent;
	}
	
	function getRawTemplateHtml() : String
	{
		var html = "";
		
		var path = getFullPath(fullTag.replace(".", "/") + "/template.html");
		if (FileSystem.exists(path))
		{
			html = File.getContent(path);
		}
		
		if (config.extend != null)
		{
			html = new ComponentTemplateParser(config.extend).getDocAndCss() + html;
		}
		
		return html;
	}
	
	public function getSupportFilePath(fileName:String) : String
	{
		var path = getFullPath(fullTag.replace('.', '/') + '/' + HaqDefines.folders.support + '/' + fileName);
		if (FileSystem.exists(path))
		{
			return path;
		}
		
		if (config.extend != null)
		{
			return getSupportFilePath(fileName);
		}
		
		return null;
	}
	
	// TODO: imports
	function getConfig() : ComponentConfig
	{
		var path = getFullPath(fullTag.replace('.', '/') + '/config.xml');
		
		var r = { extend:null, imports:new Array<String>() };
		
		if (FileSystem.exists(path))
		{
			var xml = new HaqXml(File.getContent(path));
			var nodes = xml.find(">component>extends");
			if (nodes.length > 0)
			{
				if (nodes[0].hasAttribute("collection"))
				{
					r.extend = nodes[0].getAttribute("collection");
				}
			}
		}
		
		return r;
	}
	
	public function getDocAndCss() : { doc:HaqXml, css:String }
	{
		var text = getRawTemplateHtml();
		
        var reSupportFileUrl = new EReg("~/([-_/\\.a-zA-Z0-9]*)", "");
        text = reSupportFileUrl.customReplace(text, function(re)
        {
            var f = getSupportFilePath(re.matched(1));
            return f != null ? '/' + f : re.matched(0);
        });
		
		var doc = new HaqXml(text);
		
		var css = '';
		var i = 0; 
		while (i < doc.children.length)
		{
			var node : HaqXmlNodeElement = doc.children[i];
			if (node.name=='style' && !node.hasAttribute('id'))
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
				doc.children.splice(i, 1);
				i--;
			}
			i++;
		}
		
		return { doc:doc, css:css };
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
	function getFullPath(path:String)
	{
		return path;
	}
	
	public function getImports() : Array<String>
	{
		return config.imports;
	}
	
	public function getServerHandlers() : Hash<Array<String>>
	{
        Lib.profiler.begin('parseServerHandlers');
            var serverMethods = [ 'click','change' ];   // server events
            var serverHandlers : Hash<Array<String>> = new Hash<Array<String>>();
            var tempObj = Type.createEmptyInstance(getClass());
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