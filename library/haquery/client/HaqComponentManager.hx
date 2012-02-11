package haquery.client;

import js.Lib;
import haquery.client.HaqComponent;
import haquery.client.HaqComponentTemplates;
using haquery.StringTools;

class HaqComponentManager 
{
    public var templates(default,null) : HaqComponentTemplates;
	var id_tag : Hash<String>;
	
	public function new(templates:HaqComponentTemplates, id_tag:Hash<String>) : Void
	{
		this.templates = templates;
		this.id_tag = id_tag;
	}
	
	public function createComponent(parent:HaqComponent, tag:String, id:String, factoryInitParams:Array<Dynamic>=null) : HaqComponent
    {
		var pageClass : Class<HaqComponent>;
		if (parent != null)
		{
			pageClass = templates.get(tag).clas;
		}
		else
		{
            var standardPageClass : Class<HaqComponent> = untyped Type.resolveClass('haquery.client.HaqPage');
            var pagePath = HaqInternals.pagePackage;
			pageClass = untyped Type.resolveClass(pagePath + '.Client');
			if (pageClass == null) 
            {
                pageClass = standardPageClass;
            }
            else
            {
                if (!HaqTools.isClassHasSuperClass(pageClass, standardPageClass))
                {
                    throw "Class '" + Type.getClassName(pageClass) + "' must be inherited from '" + Type.getClassName(standardPageClass) + "'.";
                }
            }
		}
		
		var component : HaqComponent = untyped Type.createInstance(pageClass, []);
        if (Reflect.isFunction(Reflect.field(component, 'construct')))
        {
            component.construct(this, parent, tag, id, templates.get(tag).elemID_serverHandlers, factoryInitParams);
        }
        else
        {
            throw "Component client class '" + Type.getClassName(pageClass) + "' must be inherited from class 'haquery.client.HaqComponent'.";
        }

        return component;
    }
    
	public function createPage() : HaqPage
    {
		var page : HaqPage = cast(createComponent(null, '', ''), HaqPage);
        return page;
    }
	
	public function getChildComponents(parent:HaqComponent) : Array<{ id:String, tag:String }>
	{
		var r : Array<{ id:String, tag:String }> = new Array<{ id:String, tag:String }>();
		var re = new EReg('^' + parent.prefixID + '[^' + HaqDefines.DELIMITER + ']+$', '');
		for (fullID in id_tag.keys())
		{
			if (re.match(fullID))
			{
				r.push({ id: fullID.substr(parent.prefixID.length), tag: id_tag.get(fullID) });
			}
		}
		return r;
	}
    
    public function getSupportUrl(tag : String)
    {
        var className = Type.getClassName(templates.get(tag).clas);
        var n = className.lastIndexOf('.');
        return '/' + className.substr(0, n).replace('.', '/') + '/' + HaqDefines.folders.support + '/';
    }
}
