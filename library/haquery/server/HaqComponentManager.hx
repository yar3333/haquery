package haquery.server;

import haquery.server.HaqComponent;
import haquery.server.HaqXml;
import haquery.server.Lib;
import haxe.Serializer;

using haquery.StringTools;

class HaqComponentManager 
{
    static var baseComponentFields : List<String> = null;
	
	var templates : HaqTemplates;
	
	var registeredScripts : Array<String>;
	var registeredStyles : Array<String>;
	
	static function __init__() : Void
	{
		var emptyComponent = Type.createEmptyInstance(HaqComponent);
		baseComponentFields = Lambda.filter(
			 Reflect.fields(emptyComponent)
			,function(field) return !Reflect.isFunction(Reflect.field(emptyComponent, field))
		);
		baseComponentFields.push('template');
	}
	
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
	 * @param	url Url to js file (global or related to support component folder).
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
	 * @param	url Url to css file (global or related to support component folder).
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
        if (!tag.startsWith('haq:')) throw "Component tag '" + tag + "' must started with 'haq:' prefix.";
		return tag.substr("haq:".length).toLowerCase().split('-').join('_');
    }
	
	public function createChildComponents(parent:HaqComponent, baseNode:HaqXmlNodeElement)
    {
		var i = 0;
		while (i < untyped __call__('count', baseNode.children))
        {
			var node : HaqXmlNodeElement = baseNode.children[i];
			Lib.assert(node.name!='haq:placeholder');
			Lib.assert(node.name!='haq:content');
            
            createChildComponents(parent, node);
            
            if (node.name.startsWith('haq:'))
            {
                node.component = createComponent(parent, node.name, node.getAttribute('id'), Lib.hashOfAssociativeArray(node.getAttributesAssoc()), node);
            }
			i++;
        }
    }
	
	public function getFieldsToLoadParams(component:HaqComponent) : Hash<String>
    {
        var r : Hash<String> = new Hash<String>(); // fieldname => FieldName
        for (field in Reflect.fields(component))
        {
            if (!Reflect.isFunction(Reflect.field(component, field))
			 && !Lambda.has(baseComponentFields, field)
             && !field.startsWith('event_')
            ) {
                r.set(field.toLowerCase(), field);
            }
        }
        return r;
    }

    public function prepareDocToRender(prefixID:String, baseNode:HaqXmlNodeElement) : Void
    {
		var i = 0;
		while (i < untyped __call__('count', baseNode.children))
        {
            var node : HaqXmlNodeElement = baseNode.children[i];
            if (node.name.startsWith('haq:'))
            {
                if (node.component == null)
                {
                    trace("Component is null: " + node.name);
                    Lib.assert(false);
                }
                
                if (node.component.visible)
                {
                    prepareDocToRender(prefixID, node);
                    
                    var text = node.component.render().trim();
                    var prev = node.getPrevSiblingNode();
                    
                    if (untyped __php__("$prev instanceof HaqXmlNodeText"))
                    {
                        var re : EReg = new EReg('(?:^|\n)([ ]+)$', 's');
                        if (re.match(cast(prev, HaqXmlNodeText).text))
                        {
                            text = text.replace("\n", "\n"+re.matched(1));
                        }
                    }
                    node.parent.replaceChild(node, new HaqXmlNodeText(text));
                }
                else
                {
                    node.remove();
                    i--;
                }
            }
            else
            {
                prepareDocToRender(prefixID, node);
                var nodeID = node.getAttribute('id');
                if (nodeID!=null && nodeID!='') node.setAttribute('id', prefixID + nodeID);
                if (node.name=='label')
                {
                    var nodeFor = node.getAttribute('for');
                    if (nodeFor!=null && nodeFor!='') 
                        node.setAttribute('for', prefixID + nodeFor);
                }
            }
			
			i++;
        }
    }
}
