package haquery.client;

import haquery.client.HaqComponent;
import haquery.client.HaqTemplate;

using haquery.StringTools;

class HaqTemplateManager extends haquery.base.HaqTemplateManager<HaqTemplate>
{
	override function fillTemplates()
	{
		for (fullTag in HaqInternals.templates.keys())
		{
			templates.set(fullTag, new HaqTemplate(fullTag));
		}
	}
	
	public function createPage(pageFullTag:String) : HaqPage
    {
		return cast newComponent(templates.get(pageFullTag), null, '', null);
    }
	
	public function createComponent(parent:HaqComponent, tag:String, id:String, factoryInitParams:Array<Dynamic>=null) : HaqComponent
    {
		return newComponent(tag.indexOf(".") < 0 ? findTemplateDeep(parent, tag) : templates.get(tag), parent, id, factoryInitParams);
    }
	
	function newComponent(template:HaqTemplate, parent:HaqComponent, id:String, factoryInitParams:Array<Dynamic>=null) : HaqComponent
	{
        var r : HaqComponent = Type.createInstance(Type.resolveClass(template.clientClassName), []);
        r.construct(this, template.fullTag, parent, id, factoryInitParams);
		return r;
	}	
	
	public function getChildComponents(parent:HaqComponent) : Array<{ id:String, fullTag:String }>
	{
		var r = new Array<{ id:String, fullTag:String }>();
		var re = new EReg('^' + parent.prefixID + '[^' + HaqDefines.DELIMITER + ']+$', '');
		for (fullID in HaqInternals.getComponentIDs().keys())
		{
			if (re.match(fullID))
			{
				r.push({ id: fullID.substr(parent.prefixID.length), fullTag: HaqInternals.getComponentIDs().get(fullID) });
			}
		}
		return r;
	}
}
