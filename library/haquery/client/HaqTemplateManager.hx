package haquery.client;

import haquery.client.HaqComponent;
import haquery.client.HaqTemplate;

using haquery.StringTools;

class HaqTemplateManager extends haquery.base.HaqTemplateManager<HaqTemplate>
{
	public function createPage(pageFullTag:String) : HaqPage
    {
		var template = new HaqTemplate(pageFullTag);
		return cast newComponent(pageFullTag, null, template.clientClass, '', null);
    }
	
	public function createComponent(parent:HaqComponent, tag:String, id:String, factoryInitParams:Array<Dynamic>=null) : HaqComponent
    {
		var template = findTemplate(parent.fullTag, tag);
		return newComponent(template.fullTag, parent, template.clientClass, id, factoryInitParams);
    }
	
	function newComponent(fulltag:String, parent:HaqComponent, clas:Class<HaqComponent>, id:String, factoryInitParams:Array<Dynamic>=null) : HaqComponent
	{
        var r : HaqComponent = Type.createInstance(clas, []);
        r.construct(this, fulltag, parent, id, factoryInitParams);
		return r;
	}	
	
	public function getChildComponents(parent:HaqComponent) : Array<{ id:String, tag:String }>
	{
		var r : Array<{ id:String, tag:String }> = new Array<{ id:String, tag:String }>();
		var re = new EReg('^' + parent.prefixID + '[^' + HaqDefines.DELIMITER + ']+$', '');
		for (fullID in HaqInternals.getComponentIDs().keys())
		{
			if (re.match(fullID))
			{
				r.push({ id: fullID.substr(parent.prefixID.length), tag: HaqInternals.getComponentIDs().get(fullID) });
			}
		}
		return r;
	}
    
    /*public function getSupportUrl(tag : String)
    {
        var className = Type.getClassName(templates.get(tag).clas);
        var n = className.lastIndexOf('.');
        return '/' + className.substr(0, n).replace('.', '/') + '/' + HaqDefines.folders.support + '/';
    }*/
}
