package haquery.server;

import haquery.server.HaqComponent;
import haquery.server.HaqXml;
import haquery.server.Lib;
import haxe.Serializer;

using haquery.StringTools;

class HaqComponentManager 
{
	var templates : HaqTemplates;
	
	var registeredScripts(default,null) : Array<String>;
	var registeredStyles(default,null) : Array<String>;
	
	public function new(templates:HaqTemplates) : Void
	{
		this.templates = templates;
		registeredScripts = [];
		registeredStyles = [];
	}
	
	function newComponent(parent:HaqComponent, clas:Class<HaqComponent>, name:String, id:String, doc:HaqXml, attr:Hash<String>, parentNode:HaqXmlNodeElement) : HaqComponent
	{
        Lib.profiler.begin('newComponent');
            var r : HaqComponent = Type.createInstance(clas, []);
            r.construct(this, parent, name, id, doc, attr, parentNode);
        Lib.profiler.end();
		return r;
	}
	
	public function createComponent(parent:HaqComponent, tagOrName:String, id:String, attr:Hash<String>, parentNode:HaqXmlNodeElement) : HaqComponent
	{
        var name : String = tagOrName.startsWith('haq:') ? getNameByTag(tagOrName) : tagOrName;
		var template = templates.get(name);
		var component : HaqComponent = newComponent(parent, template.serverClass, name, id, template.doc, attr, parentNode);
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
    
	function getSupportRelatedUrl(tag:String, url:String) : String
	{
		if (url.startsWith("~/"))
		{
			url = url.substr(2);
		}
		else
		if (!url.startsWith("http://") && !url.startsWith("/"))
		{
			url = templates.getSupportPath(tag) + url;
		}
		return url;
	}
	
	/**
	 * Tells HaQuery to load JS file from support component folder.
	 * @param	tag Component name.
	 * @param	url Url to js file (related to support component folder).
	 */
    public function registerScript(tag:String, url:String) : Void
	{
		url = getSupportRelatedUrl(tag, url);
		if (!Lambda.has(registeredScripts, url))
		{
			registeredScripts.push(url);
		}
	}
	
	/**
	 * Tells HaQuery to load CSS file from support component folder.
	 * @param	tag Component name.
	 * @param	url Url to css file (related to support component folder).
	 */
	public function registerStyle(tag:String, url:String) : Void
	{
		url = getSupportRelatedUrl(tag, url);
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
	
	public function getInternalDataForPageHtml(page:HaqPage, path:String) : String
    {
		var s = '';
        
        var tags = templates.getTags();
        s += "haquery.client.HaqInternals.tags = [\n";
        var tagComponents = getTagComponents(page);
        for (tag in tagComponents.keys())
        {
            var components = tagComponents.get(tag);
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
    
    function getTagComponents(page:HaqPage) : Hash<Array<HaqComponent>>
    {
        var r = new Hash<Array<HaqComponent>>();
        getTagComponents_fill(page, r);
        return r;
    }
    
    function getTagComponents_fill(component:HaqComponent, r:Hash<Array<HaqComponent>>)
    {
        for (child in component.components)
        {
            var tag = child.tag;
            if (!r.exists(tag)) r.set(tag, new Array<HaqComponent>());
            r.get(child.tag).push(child);
            getTagComponents_fill(child, r);
        }
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
