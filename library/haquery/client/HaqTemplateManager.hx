package haquery.client;

import haquery.client.HaqComponent;
import haquery.client.HaqTemplate;
import haquery.common.HaqDefines;

using haquery.StringTools;

class HaqTemplateManager extends haquery.base.HaqTemplateManager<HaqTemplate>
{
	public function new()
	{
		super();
		
		for (fullTag in HaqInternals.templates.keys())
		{
			templates.set(fullTag, new HaqTemplate(fullTag));
		}
		
		sharedStorage = HaqInternals.sharedStorage;
	}
	
	public function createPage(pageFullTag:String) : HaqPage
    {
		return cast(newComponent(get(pageFullTag), null, '', null), HaqPage);
    }
	
	public function createComponent(parent:HaqComponent, fullTag:String, id:String, isDynamic:Bool, dynamicParams:Dynamic=null) : HaqComponent
    {
		return newComponent(get(fullTag), parent, id, isDynamic, dynamicParams);
    }
	
	function newComponent(template:HaqTemplate, parent:HaqComponent, id:String, isDynamic:Bool, dynamicParams:Dynamic=null) : HaqComponent
	{
        var r : HaqComponent = Type.createInstance(Type.resolveClass(template.clientClassName), []);
		r.construct(this, template.fullTag, parent, id, isDynamic, dynamicParams);
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
