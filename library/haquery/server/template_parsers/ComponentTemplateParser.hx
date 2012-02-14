package haquery.server.template_parsers;

import haquery.server.HaqDefines;
import haquery.server.HaqXml;
import php.FileSystem;
import php.io.File;
import php.NativeArray;
import php.Lessc;
import haquery.server.HaqComponent;

using haquery.StringTools;

class ComponentTemplateParser extends BaseTemplateParser
{
	var collection : String;
	var tag : String;
	
	var config : ComponentConfig;
	
	public function new(collection:String, tag:String)
	{
		this.collection = collection;
		this.tag = tag;
		
		config = getConfig();
	}
	
	override public function getServerClass() : Class<HaqComponent>
	{
		var className = HaqDefines.folders.components + "." + collection + "." + tag + ".Server";
		var clas = Type.resolveClass(className);
		if (clas != null)
		{
			return cast clas;
		}
		
		if (config.extendsCollection != null)
		{
			return new ComponentTemplateParser(config.extendsCollection, tag).getServerClass();
		}
		
		return HaqComponent;
	}
	
	function getRawTemplateHtml() : String
	{
		var html = "";
		
		var path = getFullPath(HaqDefines.folders.components + '/' + collection + '/' + tag + '/template.html');
		if (FileSystem.exists(path))
		{
			html = File.getContent(path);
		}
		
		if (config.extendsCollection != null)
		{
			html = new ComponentTemplateParser(config.extendsCollection, tag).getDocAndCss() + html;
		}
		
		return html;
	}
	
	override public function getSupportFilePath(fileName:String) : String
	{
		var path = getFullPath(HaqDefines.folders.components + '/' + collection + '/' + tag + '/' + HaqDefines.folders.support + '/' + fileName);
		if (FileSystem.exists(path))
		{
			return path;
		}
		
		if (config.extendsCollection != null)
		{
			return getSupportFilePath(fileName);
		}
		
		return null;
	}
	
	function getConfig() : ComponentConfig
	{
		var path = getFullPath(HaqDefines.folders.components + '/' + collection + '/' + tag + '/config.xml');
		
		var r = { extendsCollection : null };
		
		if (FileSystem.exists(path))
		{
			var xml = new HaqXml(File.getContent(path));
			var nodes = xml.find(">component>extends");
			if (nodes.length > 0)
			{
				if (nodes[0].hasAttribute("collection"))
				{
					r.extendsCollection = nodes[0].getAttribute("collection");
				}
			}
		}
		
		return r;
	}
	
	override public function getDocAndCss() : { doc:HaqXml, css:String }
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
					css += globalizeCssClassNames(new Lessc().parse(node.innerHTML));
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
				r += blocks.matched(0).replace(".", "." + (tag != "" ? tag + HaqDefines.DELIMITER : ""));
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
	
	override public function getCollectionName() : String
	{
		return collection;
	}
	
	override public function getExtendsCollectionName() : String
	{
		return config.extendsCollection;
	}
}