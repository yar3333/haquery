package haquery.server;

import haxe.htmlparser.HtmlDocument;

class HaqTemplateConfig extends haquery.base.HaqTemplateConfig
{
	public var imports(default, null) : Array<String>;
	public var maps(default, null) : Hash<Array<String>>;
	
	public function new(base:HaqTemplateConfig, xml:HtmlDocument)
	{
		super(base != null ? base.extend : null);
		imports = [];
		maps = base != null ? base.maps : new Hash<Array<String>>();
		
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
				if (mapComponentNode.hasAttribute("tag") && mapComponentNode.hasAttribute("package"))
				{
					var tag = mapComponentNode.getAttribute("tag");
					var pack = mapComponentNode.getAttribute("package");
					if (!maps.exists(tag))
					{
						maps.set(tag, [ pack ]);
					}
					else
					{
						maps.get(tag).unshift(pack);
					}
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
