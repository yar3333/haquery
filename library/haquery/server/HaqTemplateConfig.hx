package haquery.server;

import haxe.htmlparser.HtmlDocument;

class HaqTemplateConfig extends haquery.base.HaqTemplateConfig
{
	public var maps(default, null) : Hash<String>;
	
	public function new(base:HaqTemplateConfig, xml:HtmlDocument)
	{
		extend = base != null ? base.extend : null;
		maps = base != null ? base.maps : new Hash<String>();
		
		if (xml != null)
		{
			var extendNodes = xml.find(">config>extend>component");
			if (extendNodes.length > 0)
			{
				if (extendNodes[0].hasAttribute("package"))
				{
					extend = extendNodes[0].getAttribute("package");
				}
			}
			
			var importComponentNodes = xml.find(">config>imports>components");
			for (importComponentNode in importComponentNodes)
			{
				if (importComponentNode.hasAttribute("package"))
				{
					imports.push(importComponentNode.getAttribute("package"));
				}
			}
			
			var mapComponentNodes = xml.find(">config>maps>component");
			for (mapComponentNode in mapComponentNodes)
			{
				if (mapComponentNode.hasAttribute("from") && mapComponentNode.hasAttribute("to"))
				{
					maps.set(mapComponentNode.getAttribute("from"), mapComponentNode.getAttribute("to"));
				}
			}
		}
		
		if (base != null)
		{
			imports = imports.concat(base.imports);
		}
	}
	
	public function noExtend()
	{
		extend = "";
	}
}
