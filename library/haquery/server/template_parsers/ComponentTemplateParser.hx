package haquery.server.template_parsers;

import haquery.server.HaqDefines;

class ComponentTemplateParser implements ITemplateParser
{
	var collection : String;
	var tag : String;
	
	var config : ComponentConfig;
	
	public function new(collection : String, tag : String)
	{
		this.collection = collection;
		this.tag = tag;
		
		config = getConfig();
	}
	
	public function getServerClass() : Class<HaqComponent>
	{
		var className = HaqDefines.folders.components + "." + collection + "." + tag + ".Server";
		var clas = Type.resolveClass(className);
		if (clas != null)
		{
			return cast clas;
		}
		
		if (config.extendsCollection != null)
		{
			return getServerClass(config.extendsCollection, tag);
		}
		
		return HaqComponent;
	}
	
	function getRawTemplateHtml() : String
	{
		var html = "";
		
		var path = HaqDefines.folders.components + '/' + collection + '/' + tag + '/template.html';
		if (FileSystem.exists(path))
		{
			html = File.getContent(path);
		}
		
		if (config.extendsCollection != null)
		{
			html = getDoc(config.extendsCollection, tag) + html;
		}
		
		return html;
	}
	
	public function findSupportFile(fileName:String) : String
	{
		var path = HaqDefines.folders.components + '/' + collection + '/' + tag + '/' + HaqDefines.folder.support + '/' + fileName;
		if (FileSystem.exists(path))
		{
			return path;
		}
		
		if (config.extendsCollection != null)
		{
			return findSupportFile(config.extendsCollection, tag, fileName);
		}
		
		return null;
	}
	
	function getConfig() : ComponentConfig
	{
		return parseConfigFile(HaqDefines.folders.components + '/' + collection + '/' + tag + '/config.xml');
	}
	
	function parseConfigFile(path:String) : ComponentConfig
	{
		var r = { extendsCollection : null };
		
		if (FileSystem.exists(path))
		{
			var xml = new HaqXml(File.getContent(path));
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
			}
		}
		
		return r;
	}
	
	function getDoc() : { css:String, doc:HaqXml }
	{
		var text = getRawTemplateHtml(collection, tag);
		
        var reSupportFileUrl = new EReg("~/([-_/\\.a-zA-Z0-9]*)", "");
        text = reSupportFileUrl.customReplace(text, function(re)
        {
            var f = getFile(collection, tag, HaqDefines.folders.support + '/' + re.matched(1));
            return f != null ? '/' + f : re.matched(0);
        });
		
		var doc = new HaqXml(text);
		
		var css = '';
		var i = 0; 
		var children : Array<HaqXmlNodeElement> = untyped Lib.toHaxeArray(doc.children);
		while (i < children.length)
		{
			var node : HaqXmlNodeElement = children[i];
			if (node.name=='style' && !node.hasAttribute('id'))
			{
				if (node.getAttribute('type') == "text/less")
				{
					css += globalizeCssClassNames(tag, (new Lessc()).parse(node.innerHTML));
				}
				else
				{
					css += globalizeCssClassNames(tag, node.innerHTML);
				}
				
				node.remove();
				children.splice(i, 1);
				i--;
			}
			i++;
		}
		
		return new HaqXml();
	}
	
	function globalizeCssClassNames(text:String) : String
	{
		var blocks = new EReg("(?:[/][*].*?[*][/])|(?:[{].*?[}])|([^{]+)|(?:[{])", "s");
		var r = "";
		while (blocks.match(text))
		{
			//trace(blocks);
			if (blocks.matched(1) == "") trace("EMPTY");
			if (blocks.matched(1) == null) trace("NULL");
			
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
}