package haquery.client;

#if client

import haquery.client.HaqComponent;
import haquery.client.HaqTemplate;
import haquery.common.HaqDefines;
import haquery.common.HaqStorage;
import models.client.Page;

class HaqTemplateManager
{
	public function new() {}
	
	public function get(fullTag:String) : HaqTemplate
	{
		return new HaqTemplate(fullTag);
	}
	
	public function createPage(fullTag:String) : Page
    {
		var page = cast(newComponent(get(fullTag), null, "", false), Page);
		
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
        var component : HaqComponent = Type.createInstance(Type.resolveClass(template.clientClassName), []);
		component.construct(template.fullTag, parent, id, isDynamic, dynamicParams);
		return component;
	}	
	
	public function getChildComponents(parent:HaqComponent) : Array<{ id:String, fullTag:String }>
	{
		var r = new Array<{ id:String, fullTag:String }>();
		var re = new EReg('^' + parent.prefixID + '[^' + HaqDefines.DELIMITER + ']+$', '');
		for (fullID in HaqInternals.getComponentIDs().keys())
		{
			if (re.match(fullID))
			{
				r.push({ id:fullID.substr(parent.prefixID.length), fullTag:HaqInternals.getComponentIDs().get(fullID) });
			}
		}
		return r;
	}
}

#end