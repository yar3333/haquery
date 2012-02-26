package haquery.server;

class HaqTemplateSelector 
{
	public function new() {}
	
	public function findTemplateToInstance(manager:HaqTemplateManager, parent:HaqComponent, tag:String) : HaqTemplate
	{
		var template = manager.findTemplate(parent.fullTag, tag);
		
		if (template == null)
		{
			var par = parent.parent;
			while (par != null)
			{
				template = manager.findTemplate(par.fullTag, tag);
				if (template != null) break;
				par = par.parent;
			}
		}
		
		return template;
	}
}