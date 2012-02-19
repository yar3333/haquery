package haquery.server;

import haxe.Serializer;
import haxe.Unserializer;

import haquery.server.HaqComponent;
import haquery.server.HaqTemplate;
import haquery.server.HaqXml;
import haquery.server.Lib;
import haquery.server.io.File;
import haquery.server.HaqTemplateParser;
import haquery.server.FileSystem;

using haquery.StringTools;
using haquery.HashTools;

class HaqTemplateManager extends haquery.base.HaqTemplateManager<HaqTemplate>
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
	
	public function new()
	{
		super();
		
		registeredScripts = [];
		registeredStyles = [];
	}
	
	override function fillTemplates()
	{
		if (!FileSystem.exists(HaqDefines.folders.temp))
		{
			FileSystem.createDirectory(HaqDefines.folders.temp);
		}
		
		var templatesCacheFilePath = HaqDefines.folders.temp + "/templates.cache";
		if (!FileSystem.exists(templatesCacheFilePath))
		{
			fillTemplatesBySearch(HaqDefines.folders.pages);
			File.putContent(templatesCacheFilePath, Serializer.run(templates));
		}
		else
		{
			templates = Unserializer.run(templatesCacheFilePath);
		}
	}
	
	public function createPage(pageFullTag:String, attr:Hash<String>) : HaqPage
	{
		var template = new HaqTemplate(pageFullTag);
        return cast newComponent(pageFullTag, null, template.serverClass, '', template.doc, attr, null);
	}
	
	public function createComponent(parent:HaqComponent, tag:String, id:String, attr:Hash<String>, parentNode:HaqXmlNodeElement) : HaqComponent
	{
		var template = findTemplate(parent.fullTag, tag);
		return newComponent(template.fullTag, parent, template.serverClass, id, template.doc, attr, parentNode);
	}
	
	function newComponent(fulltag:String, parent:HaqComponent, clas:Class<HaqComponent>, id:String, doc:HaqXml, attr:Hash<String>, parentNode:HaqXmlNodeElement) : HaqComponent
	{
        Lib.profiler.begin('newComponent');
            var r : HaqComponent = Type.createInstance(clas, []);
            r.construct(this, fulltag, parent, id, doc, attr, parentNode);
        Lib.profiler.end();
		return r;
	}
	
	function getFullUrl(fullTag:String, url:String) : String
	{
		if (url.startsWith("~/"))
		{
			url = url.substr(2);
		}
		
		if (!url.startsWith("http://") && !url.startsWith("/") && !url.startsWith("<"))
		{
			url = '/' + templates.get(fullTag).getSupportFilePath(url);
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
	
	function generatePackageCssFile(pack:String, fullTags:Array<String>, forceUpdate = false) : String
	{
		var path = HaqDefines.folders.temp + '/styles/' + pack + '.css';
		
		var text = "";
		for (fullTag in fullTags)
		{
			var template = templates.get(fullTag);
			text += "/* " + fullTag + "*/\n" + template.css + "\n\n";
		}
		
		File.putContent(path, text);
		
		return path;
	}
	
	public function getRegisteredStyles() : Array<String>
	{
		var packageStyles = [];
		var usedPackages = getPackages();
		for (pack in usedPackages.keys())
		{
			packageStyles.push(generatePackageCssFile(pack, usedPackages.get(pack)));
		}
		return packageStyles.concat(registeredStyles);
	}
	
	public function getRegisteredScripts() : Array<String>
	{
		return registeredScripts;
	}
	
	/**
	 * 
	 * @return package => [ fullTag0, fullTag1, ... ]
	 */
	function getPackages() : Hash<Array<String>>
	{
		var r = new Hash<Array<String>>();
		for (fullTag in templates.keys())
		{
			var pack = getPackageByFullTag(fullTag);
			if (!r.exists(pack))
			{
				r.set(pack, []);
			}
			r.get(pack).push(fullTag);
		}
		return r;
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
	
	public function getDynamicClientCode(pageFullTag:String) : String
    {
		var s = '';
		
        // TODO: getSystemInitClientCode
		
		/*
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
		*/

        return s;
    }
	
	public function getStaticClientCode() : String
	{
		return "";
	}
}
