package haquery.server;

import haquery.server.HaqComponent;
import haquery.server.HaqXml;
import haquery.server.Lib;
import haxe.Serializer;

using haquery.StringTools;

class HaqComponentManager 
{
	var templates : HaqTemplates;
	var tag_id_component : Hash<Array<HaqComponent>>;
	
	var registeredScripts(default,null) : Array<String>;
	var registeredStyles(default,null) : Array<String>;
	
	public function new(templates:HaqTemplates) : Void
	{
		this.templates = templates;
		tag_id_component = new Hash<Array<HaqComponent>>();
		registeredScripts = [];
		registeredStyles = [];
	}
	
	function newComponent(parent:HaqComponent, clas:Class<HaqComponent>, name:String, id:String, doc:HaqXml, attr:Hash<String>, innerHTML:String) : HaqComponent
	{
        Lib.profiler.begin('newComponent');
            var r : HaqComponent = Type.createInstance(clas, []);
            r.construct(this, parent, name, id, doc, attr, innerHTML);
        Lib.profiler.end();
		return r;
	}
	
	public function createComponent(parent:HaqComponent, tagOrName:String, id:String, attr:Hash<String>, innerHTML:String) : HaqComponent
	{
        var name : String = tagOrName.startsWith('haq:') ? getNameByTag(tagOrName) : tagOrName;
		var template = templates.get(name);
		var component : HaqComponent = newComponent(parent, template.serverClass, name, id, template.doc, attr, innerHTML);
		if (!tag_id_component.exists(name)) tag_id_component.set(name, new Array<HaqComponent>());
		tag_id_component.get(name).push(component);
		return component;
	}
	
	public function createPage(path:String, attr:Hash<String>) : HaqPage
	{
		var className = path.replace('/', '.') + '.Server';
		
        var standardPageClass = Type.resolveClass('haquery.server.HaqPage');
        var pageClass = Type.resolveClass(className);
        if (pageClass == null)
        {
            pageClass = standardPageClass;
        }
        else
        {
            if (!HaqTools.isClassHasSuperClass(pageClass, standardPageClass))
            {
                throw "Class '" + className + "' must be inherited from '" + Type.getClassName(standardPageClass) + "'.";
            }
        }
		
		var doc = templates.getPageTemplateDoc(path);
        var page : HaqPage = cast(newComponent(null, cast pageClass, '', '', doc, attr, null), HaqPage);
        return page;
	}
    
	/**
	 * Tells HaQuery to add html code to load file from support component folder.
	 * @param	tag Component name.
	 * @param	url Url to js file related to component support folder.
	 */
    public function registerScript(tag:String, url:String) : Void
	{
		url = templates.getSupportPath(tag) + url;
		
		if (!Lambda.has(registeredScripts, url))
		{
			registeredScripts.push(url);
		}
	}
	
	public function registerStyle(tag:String, url:String) : Void
	{
        url = templates.getSupportPath(tag) + url;
		
		if (!Lambda.has(registeredStyles, url))
		{
			registeredStyles.push(url);
		}
	}
	
	public function getRegisteredScripts() : Array<String>
	{
		return registeredScripts;
	}
	
	public function getRegisteredStyles() : Array<String>
	{
		return registeredStyles;
	}
	
	public function getInternalDataForPageHtml(path:String) : String
    {
		var s = '';
        
        var tags = templates.getTags();
        s += "haquery.client.HaqInternals.tags = [\n";
        for (tag in tag_id_component.keys())
        {
            var components = tag_id_component.get(tag);
            var visibledComponents =  Lambda.filter(components, function (x) {
                while (x != null)
                {
                    if (!x.visible) return false;
                    x = x.parent;
                }
                return true;
            });
			var ids =  Lambda.map(visibledComponents, function(x) { return x.fullID; } ).join(',');
			s += "    ['" + tag + "', '" + ids + "'],\n";
        }
        s = s.rtrim("\n,") + "\n];\n";
		
        var serverHandlers = new Hash<Hash<Array<String>>>();
        serverHandlers.set('', templates.parseServerHandlers(path));
        for (tag in tags)
        {
            serverHandlers.set(tag, templates.get(tag).serverHandlers);
        }
        s += "haquery.client.HaqInternals.serializedServerHandlers = \"" + Serializer.run(serverHandlers) + "\";\n";
        
        s += "haquery.client.HaqInternals.pagePackage = \"" + path.replace('/', '.') + "\";";

        return s;
    }
	
    public function getSupportPath(tag:String) : String
    {
		return templates.getSupportPath(tag);
    }
	
    function getNameByTag(tag:String) : String
    {
        if (!tag.startsWith('haq:')) throw "Component tag '"+tag+"' must started with 'haq:' prefix.";
		return tag.substr("haq:".length).toLowerCase().split('-').join('_');
    }
    
}
