package haquery.server;

import haquery.server.HaqComponent;
import haquery.server.HaqXml;
import php.Lib;

class HaqComponentManager 
{
	var templates : HaqTemplates;
	var tag2id2component : Hash<Array<HaqComponent>>;
	
	var registeredScripts(default,null) : Array<String>;
	var registeredStyles(default,null) : Array<String>;
	
	public function new(templates:HaqTemplates) : Void
	{
		this.templates = templates;
		tag2id2component = new Hash<Array<HaqComponent>>();
		registeredScripts = [];
		registeredStyles = [];
	}
	
	function newComponent(parent:HaqComponent, clas:Class<HaqComponent>, name:String, id:String, doc:HaqXml, attr:Hash<String>, innerHTML:String) : HaqComponent
	{
		var r = Type.createInstance(clas, []);
		r.construct(this, parent, name, id, doc, attr, innerHTML);
		return r;
	}
	
	public function createComponent(parent:HaqComponent, tagOrName:String, id:String, attr:Hash<String>, innerHTML:String) : HaqComponent
	{
        var name : String = tagOrName.startsWith('haq:') ? getNameByTag(tagOrName) : tagOrName;
		var template = templates.get(name);
		var component : HaqComponent = newComponent(parent, template.serverClass, name, id, template.doc, attr, innerHTML);
		if (!tag2id2component.exists(name)) tag2id2component.set(name, new Array<HaqComponent>());
		tag2id2component.get(name).push(component);
		return component;
	}
	
	public function createPage(clas:Class<HaqPage>, doc:HaqXml, attr:Hash<String>) : HaqPage
	{
		processPlaceholders(doc);
		var component : HaqComponent = newComponent(null, untyped clas, '', '', doc, attr, null);
		return untyped component;
	}
    
	public function registerScript(tag:String, urlToJs:String) : Void
	{
		/*if (urlToCss.startsWith('~/'))
		{
			templates.getStyleFilePaths
		}*/
		
		if (registeredScripts.indexOf(urlToJs) == -1)
		{
			registeredScripts.push(urlToJs);
		}
	}
	
	public function registerStyle(tag:String, urlToCss:String) : Void
	{
		if (registeredStyles.indexOf(urlToCss) == -1)
		{
			registeredStyles.push(urlToCss);
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
	
	public function getInternalDataForPageHtml() : String
    {
		var tags = templates.getTags();
			  
        var s = "haquery.client.HaqInternals.serverHandlers = [\n";
        for (tag in tags)
        {
            var info = templates.get(tag);
			if (info.serverHandlers.keys().hasNext())
			{
                s += "    ['" + tag + "',\n";
				for (id in info.serverHandlers.keys())
				{
					s += "        ['" + id + "', '" + info.serverHandlers.get(id).join(',') + "'],\n";
				}
				s = s.rtrim("\n,") + "\n    ],\n";
			}
        }
        s = s.rtrim("\n,") + "\n];\n";

        s += "haquery.client.HaqInternals.tags = [\n";
        for (tag in tag2id2component.keys())
        {
            var components = tag2id2component.get(tag);
			var ids = Lambda.map(components, function(x:HaqComponent):String { return x.fullID; } ).join(',');
			s += "    ['" + tag + "', '" + ids + "'],\n";
        }
        s = s.rtrim("\n,") + "\n];";

        return s;
    }
	
	static function getNameByTag(tag:String) : String
    {
        if (!tag.startsWith('haq:')) throw "Component tag '"+tag+"' must started with 'haq:' prefix.";
		return tag.substr("haq:".length).toLowerCase().split('-').join('_');
    }
	
    static function processPlaceholders(doc : HaqXml)
    {
        var placeholders : Array<HaqXmlNodeElement> = untyped Lib.toHaxeArray(doc.find('haq:placeholder'));
        var contents : Array<HaqXmlNodeElement> = untyped Lib.toHaxeArray(doc.find('>haq:content'));
        for (ph in placeholders)
        {
            var content : HaqXmlNodeElement = null;
            for (c in contents) 
            {
                if (c.getAttribute('id')==ph.getAttribute('id'))
                {
                    content = c;
                    break;
                }
            }
            if (content!=null) ph.parent.replaceChildWithInner(ph, content);
            else               ph.parent.replaceChildWithInner(ph, ph);
        }
        
        for (c in contents) c.remove();
    }
}
