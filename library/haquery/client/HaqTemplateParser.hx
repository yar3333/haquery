package haquery.client;

import haquery.base.HaqTemplateParser.HaqTemplateNotFoundException;

using haquery.StringTools;

class HaqTemplateParser extends haquery.base.HaqTemplateParser<HaqTemplateConfig>
{
	public function new(fullTag:String)
	{
		super(fullTag);
	}
	
	override function isTemplateExist(fullTag:String) : Bool
	{
		return HaqInternals.templates.exists(fullTag);
	}
	
	override function getParentParser() : HaqTemplateParser
	{
		if (config.extend == null || config.extend == "") return null; 
		
		try
		{
			return new HaqTemplateParser(config.extend);
		}
		catch (e:HaqTemplateNotFoundException)
		{
			return null;
		}
	}
	
	override function getShortClassName() : String
	{
		return "Client";
	}
	
	override function getConfig() : HaqTemplateConfig
	{
		return HaqInternals.getTemplateConfig(fullTag);
	}
	
	public function getServerHandlers() : Hash<Array<String>>
	{
		return HaqInternals.getServerHandlers(fullTag);
	}
}