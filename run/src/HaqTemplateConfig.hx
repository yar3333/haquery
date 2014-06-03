package ;

import htmlparser.HtmlDocument;
import haquery.common.HaqTemplateExceptions;
import haquery.server.HaqTemplateTools;
import stdlib.Std;

class HaqTemplateConfig
{
	public var extend : String;
	public var imports(default, null) : Array<{ component:String, asTag:String }>;
	public var requires(default, null) : Array<String>;
	
	public function new(base:HaqTemplateConfig, xml:HtmlDocument)
	{
		extend = base != null ? base.extend : "";
		imports = [];
		requires = base != null ? base.requires : [];
		
		if (xml != null)
		{
			var extendNodes = xml.find(">config>extends");
			if (extendNodes.length > 0)
			{
				if (extendNodes.length > 1)
				{
					throw new HaqTemplateConfigParseException("Several 'extends' tags is not possible.");
				}
				
				if (extendNodes[0].hasAttribute("component"))
				{
					extend = extendNodes[0].getAttribute("component");
					if (extend != "" && !(~/^(?:[_a-z][_a-z0-9]*[.])+(?:[_a-z][_a-z0-9]*)$/i.match(extend)))
					{
						throw new HaqTemplateConfigParseException("Invalid value of 'component' attribute for 'extends' tag.");
					}
				}
				else
				{
					throw new HaqTemplateConfigParseException("Tag 'extends' must have 'component' attribute.");
				}
			}
			
			var importNodes = xml.find(">config>import");
			for (importNode in importNodes)
			{
				if (importNode.hasAttribute("component"))
				{
					var componentPack = importNode.getAttribute("component");
					
					if ((~/^(?:[_a-z][_a-z0-9]*[.])+[*]$/i.match(componentPack)))
					{
						imports.unshift({ component:HaqTemplateTools.getPack(componentPack), asTag:null });
					}
					else
					if (~/^(?:[_a-z][_a-z0-9]*[.])+[_a-z][_a-z0-9]*$/i.match(componentPack))
					{
						if (Std.bool(importNode.getAttribute("required")))
						{
							requires.push(componentPack);
						}
						var asTag = importNode.hasAttribute("as") ? importNode.getAttribute("as") : HaqTemplateTools.getTag(componentPack);
						imports.unshift({ component:componentPack, asTag:asTag });
					}
					else
					{
						throw new HaqTemplateConfigParseException("Invalid value of 'component' attribute for 'import' tag.");
					}
				}
				else
				{
					throw new HaqTemplateConfigParseException("Tag 'import' must have 'component' attribute.");
				}
			}
		}
		
		if (base != null)
		{
			imports = imports.concat(base.imports);
		}
	}
}
