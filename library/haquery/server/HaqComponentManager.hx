package haquery.server;

import haquery.server.HaqComponent;
import haquery.server.HaqXml;
import haquery.server.Lib;
import haquery.server.template_parsers.ComponentTemplateParser;
import haquery.server.template_parsers.PageTemplateParser;
import haxe.Serializer;
import haquery.server.FileSystem;

using haquery.StringTools;

class HaqComponentManager extends haquery.base.HaqComponentManager
{
    static var baseComponentFields : List<String> = null;
	
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
	
	public function new(pageFullTag:String, pageAttr:Hash<String>)
	{
		registeredScripts = [];
		registeredStyles = [];
		super(pageFullTag, pageAttr);
	}
	
	function newComponent(fulltag:String, parent:HaqComponent, clas:Class<HaqComponent>, id:String, doc:HaqXml, attr:Hash<String>, parentNode:HaqXmlNodeElement) : HaqComponent
	{
        Lib.profiler.begin('newComponent');
            var r : HaqComponent = Type.createInstance(clas, []);
            r.construct(this, fulltag, parent, id, doc, attr, parentNode);
        Lib.profiler.end();
		return r;
	}
	
	public function createComponent(parent:HaqComponent, tag:String, id:String, attr:Hash<String>, parentNode:HaqXmlNodeElement) : HaqComponent
	{
		var fullTag = getFullTag(parent, tag);
		var template =  getTemplate(fullTag);
		var component : HaqComponent = newComponent(fullTag, parent, template.serverClass, id, template.doc, attr, parentNode);
		return component;
	}
	
	override function createPage(pageFullTag:String, attr:Hash<String>) : HaqPage
	{
		var template = new HaqTemplate(new PageTemplateParser(pageFullTag));
		
		if (!HaqTools.isClassHasSuperClass(template.serverClass, haquery.server.HaqPage))
		{
            // TODO: class type check
			//throw "Class '" + Type.getClassName(template.serverClass) + "' must be inherited from '" + Type.getClassName(standardPageClass) + "'.";
		}
		
        return cast newComponent(pageFullTag, null, template.serverClass, '', template.doc, attr, null);
	}
    
	function getFullUrl(fullTag:String, url:String) : String
	{
		if (url.startsWith("~/"))
		{
			url = url.substr(2);
		}
		
		if (!url.startsWith("http://") && !url.startsWith("/") && !url.startsWith("<"))
		{
			url = '/' + getTemplate(fullTag).getSupportFilePath(url);
		}
		
		return url;
	}
	
	/**
	 * Tells HaQuery to load JS file from support component folder.
	 * @param	fullTag Component package name.
	 * @param	url Url to js file (global or related to support component folder).
	 */
    public function registerScript(fullTag:String, url:String) : Void
	{
		url = getFullUrl(fullTag, url);
		if (!Lambda.has(registeredScripts, url))
		{
			registeredScripts.push(url);
		}
	}
	
	/**
	 * Tells HaQuery to load CSS file from support component folder.
	 * @param	fullTag Component package name.
	 * @param	url Url to css file (global or related to support component folder).
	 */
	public function registerStyle(fullTag:String, url:String) : Void
	{
		url = getFullUrl(fullTag, url);
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
	
	public function getInternalDataForPageHtml(page:HaqPage) : String
    {
		// TODO: getInternalDataForPageHtml
		return '';
		
/*		var s = '';
		
        s += "haquery.client.HaqInternals.componentCollections = [ " + Lambda.map(collections, function(c) return "'" + c + "'").join(', ') + " ];\n";
        
        var tags = templates.keys();
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
		
		var pageClassName = Type.getClassName(Type.getClass(page));
		var pageTemplate = new HaqTemplate(new PageTemplateParser(pageClassName));
		var serverHandlers = new Hash<Hash<Array<String>>>();
        serverHandlers.set('', pageTemplate.serverHandlers);
        for (tag in tags)
        {
            serverHandlers.set(tag, templates.get(tag).serverHandlers);
        }
        s += "haquery.client.HaqInternals.serializedServerHandlers = \"" + Serializer.run(serverHandlers) + "\";\n";
        s += "haquery.client.HaqInternals.pagePackage = \"" + pageClassName + "\";";

        return s;
*/
    }
    
    function getFullTagComponents(page:HaqPage) : Hash<Array<HaqComponent>>
    {
        var r = new Hash<Array<HaqComponent>>();
        getFullTagComponents_fill(page, r);
        return r;
    }
    
    function getFullTagComponents_fill(component:HaqComponent, r:Hash<Array<HaqComponent>>)
    {
        for (child in component.components)
        {
            var fullTag = child.fullTag;
            if (!r.exists(fullTag)) r.set(fullTag, new Array<HaqComponent>());
            r.get(child.fullTag).push(child);
            getFullTagComponents_fill(child, r);
        }
    }
	
    /*function getNameByTag(tag:String) : String
    {
        if (!tag.startsWith('haq:')) throw "Component tag '" + tag + "' must started with 'haq:' prefix.";
		return tag.substr("haq:".length).toLowerCase().split('-').join('_');
    }*/
	
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
                node.component = createComponent(parent, node.name.substr('haq:'.length), node.getAttribute('id'), node.getAttributesAssoc(), node);
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
			 && (field == 'visible' || !Lambda.has(baseComponentFields, field))
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
                    
                    var text : String = node.component.render().trim();
                    var prev = node.getPrevSiblingNode();
                    
                    if (Type.getClass(prev) == HaqXmlNodeText)
                    {
                        var re : EReg = new EReg('(?:^|\n)([ ]+)$', 's');
                        if (re.match(cast(prev, HaqXmlNodeText).text))
                        {
                            text = text.replace("\n", "\n" + re.matched(1));
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
                if (nodeID != null && nodeID != '')
				{
					node.setAttribute('id', prefixID + nodeID);
				}
                if (node.name == 'label')
                {
                    var nodeFor = node.getAttribute('for');
                    if (nodeFor != null && nodeFor != '')
					{
						node.setAttribute('for', prefixID + nodeFor);
					}
                }
            }
			
			i++;
        }
    }
	
	/*public function getTemplateHtml(tag:String) : String
	{
		return templates.get(tag).doc.toString();
	}*/
	
	/*
	function createDirectory(path:String)
	{
		var parentPath = Path.directory(path);
		if (parentPath != null && parentPath != '' && !FileSystem.exists(parentPath)) createDirectory(parentPath);
		FileSystem.createDirectory(path);
	}*/
    
    /*public function getSupportPath(tag:String) : String
    {
        return getFileUrl(tag, HaqDefines.folders.support) + '/';
    }*/
}
