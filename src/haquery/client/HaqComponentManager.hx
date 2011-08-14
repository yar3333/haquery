package haquery.client;

import js.Lib;
import haquery.client.HaqComponent;
import haquery.client.HaqTemplates;

class HaqComponentManager 
{
    var templates : HaqTemplates;
	var id_tag : Hash<String>;
	
	public function new(templates:HaqTemplates, id_tag:Hash<String>) : Void
	{
		this.templates = templates;
		this.id_tag = id_tag;
	}
	
	public function createComponent(parent:HaqComponent, tag:String, id:String) : HaqComponent
    {
		var clas : Class<HaqComponent>;
		if (parent != null)
		{
			clas = templates.get(tag).clas;
		}
		else
		{
			var pagePath = Lib.window.location.pathname; 
			if (pagePath.endsWith("/")) pagePath = pagePath.substr(0, pagePath.length - 1);
			if (pagePath == '') pagePath = 'index';
			var className = 'pages.' + pagePath.replace('/', '.') + '.Client';
			clas = untyped Type.resolveClass(className);
			if (clas == null) clas = untyped Type.resolveClass('haquery.client.HaqPage');
		}
		
		var component : HaqComponent = untyped Type.createInstance(clas, []);
        if (Reflect.hasMethod(component, 'construct'))
        {
            component.construct(this, parent, tag, id, templates.get(tag).elemID_serverHandlers);
        }
        else
        {
            throw "Component client class '"+Type.getClassName(clas)+"' must be inherited from class 'haquery.client.HaqComponent'.";
        }

        return component;
    }
    
	public function createPage() : HaqPage
    {
		return cast(createComponent(null, '', ''), HaqPage);
    }
	
	public function getChildComponents(parent:HaqComponent) : Array<{ id:String, tag:String }>
	{
		var r : Array<{ id:String, tag:String }> = new Array<{ id:String, tag:String }>();
		var re = new EReg('^'+parent.prefixID+'[^'+HaqInternals.DELIMITER+']+$', '');
		for (fullID in id_tag.keys())
		{
			if (re.match(fullID))
			{
				r.push({ id: fullID.substr(parent.prefixID.length), tag: id_tag.get(fullID) });
			}
		}
		return r;
	}
}
