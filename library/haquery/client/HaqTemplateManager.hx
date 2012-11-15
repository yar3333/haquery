package haquery.client;

import haquery.client.HaqComponent;
import haquery.client.HaqTemplate;
import haquery.common.HaqDefines;
import haquery.common.HaqSharedStorage;

class HaqTemplateManager
{
	/**
	 * Vars sended from the server.
	 */
	public var sharedStorage(default, null) : HaqSharedStorage;
	
	public function new()
	{
		this.sharedStorage = HaqInternals.sharedStorage;
	}
	
	public function get(fullTag:String) : HaqTemplate
	{
		return new HaqTemplate(fullTag);
	}
	
	public function createPage(pageFullTag:String) : HaqPage
    {
		var component = newComponent(get(pageFullTag), null, "", null);
		
		var page = cast(component, HaqPage);
		
		page.forEachComponent("preInit", true);
		page.forEachComponent("init", false);

		return page;
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
