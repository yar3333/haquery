package haquery.client;

using haquery.StringTools;

class HaqTemplateParser extends haquery.base.HaqTemplateParser
{
	public function new(fullTag:String)
	{
		super(fullTag);
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