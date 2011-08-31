package haquery.server;

import haquery.server.HaqComponent;
import haquery.server.HaqXml;
import haxe.Serializer;
import php.Lib;

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
		var r : HaqComponent = Type.createInstance(clas, []);
		r.construct(this, parent, name, id, doc, attr, innerHTML);
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
		if (Type.resolveClass(className)==null) className = 'haquery.server.HaqPage';
		var pageClass = Type.resolveClass(className);
		
		var doc = HaqTemplates.getPageTemplateDoc(path);
		var page : HaqPage = cast(newComponent(null, cast pageClass, '', '', doc, attr, null), HaqPage);
		return page;
	}
    
	public function registerScript(tag:String, url:String) : Void
	{
		url = templates.getFileUrl(tag, HaQuery.folders.support) + '/' + url;
		
		if (registeredScripts.indexOf(url) == -1)
		{
			registeredScripts.push(url);
		}
	}
	
	public function registerStyle(tag:String, url:String) : Void
	{
        url = templates.getFileUrl(tag, HaQuery.folders.support) + '/' + url;
		
		if (registeredStyles.indexOf(url) == -1)
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
			var ids = Lambda.map(components, function(x:HaqComponent):String { return x.fullID; } ).join(',');
			s += "    ['" + tag + "', '" + ids + "'],\n";
        }
        s = s.rtrim("\n,") + "\n];\n";
		
        var serverHandlers = new Hash<Hash<Array<String>>>();
        serverHandlers.set('', HaqTemplates.parseServerHandlers(path));
        for (tag in tags)
        {
            serverHandlers.set(tag, templates.get(tag).serverHandlers);
        }
        s += "haquery.client.HaqInternals.serializedServerHandlers = \"" + Serializer.run(serverHandlers) + "\";";

        return s;
    }
	
    public function getSupportPath(tag:String):String
    {
		return templates.getFileUrl(tag, HaQuery.folders.support) + '/';
    }
	
    function getNameByTag(tag:String) : String
    {
        if (!tag.startsWith('haq:')) throw "Component tag '"+tag+"' must started with 'haq:' prefix.";
		return tag.substr("haq:".length).toLowerCase().split('-').join('_');
    }
    
}
