package ;

import haxe.htmlparser.HtmlDocument;

class HaqTemplateConfig extends haquery.server.HaqTemplateConfig
{
    public var requires : Array<String>;
	
	public function new(base:HaqTemplateConfig, xml:HtmlDocument)
	{
		super(base, xml);
		
		requires = base != null ? base.requires : [];
		
		if (xml != null)
		{
			for (node in xml.find(">config>requires>component"))
			{
				requires.push(node.getAttribute("package"));
			}
		}
	}
}
