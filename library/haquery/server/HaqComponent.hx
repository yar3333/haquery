package haquery.server;

import haquery.Exception;
import haquery.Std;
import haquery.server.HaqCssGlobalizer;
import haxe.htmlparser.HtmlDocument;
import haxe.htmlparser.HtmlNodeElement;
import haxe.htmlparser.HtmlNodeText;
import haquery.server.Lib;
import haquery.server.HaqComponentTools;
import haxe.Serializer;

using haquery.StringTools;

@:autoBuild(haquery.macros.HaqComponent.build()) class HaqComponent extends haquery.base.HaqComponent
{
    /**
     * template.html as DOM tree.
     */
    public var doc(default, null) : HtmlDocument;
    
    /**
     * HTML element, which contain this component.
     */
    public var innerNode(default, null) : HtmlNodeElement;
    
	/**
	 * True for components declared inside another components (i.e. between tags (<haq:*>...</haq:*>).
	 */
	public var isInnerComponent(default, null) : Bool;
	
    /**
     * These components was declared between <haq:*> and </haq:*> tags of this component.
     */
	var innerComponents : Array<HaqComponent>;
	
	/**
     * Need render?
     */
    public var visible : Bool;
    
	public function new() : Void
	{
		super();
		
		innerComponents = [];
		visible = true;
	}
    
    public function construct(manager:HaqTemplateManager, fullTag:String, parent:HaqComponent, id:String, doc:HtmlDocument, params:Hash<String>, innerNode:HtmlNodeElement, isInnerComponent:Bool) : Void
    {
		super.commonConstruct(manager, fullTag, parent, id);
        
        this.doc = doc;
        this.innerNode = innerNode;
		this.isInnerComponent = isInnerComponent;
		
		if (params != null)
		{
			Lib.profiler.begin("loadFieldValues");
			loadFieldValues(params);
			Lib.profiler.end();
		}
        
		Lib.profiler.begin("createEvents");
		createEvents();
		Lib.profiler.end();
        
		Lib.profiler.begin("createChildComponents");
		createChildComponents();
		Lib.profiler.end();
		
        if (Reflect.isFunction(Reflect.field(this, 'init')))
        {
			Lib.profiler.begin("init");
            if (Lib.config.isTraceComponent)
			{
				trace("HAQUERY [" + fullID + "] " + fullTag + ".init...");
			}
			Reflect.callMethod(this, Reflect.field(this, 'init'), []);
			Lib.profiler.end();
        }
    }
	
	function loadFieldValues(params:Hash<String>) : Void
	{
		var fields = HaqComponentTools.getFieldsToLoadParams(this);
		
		for (k in params.keys())
		{
			var v : Dynamic = params.get(k);
			k = k.toLowerCase();
			if (fields.exists(k) || fields.exists(k + "_"))
			{
				var field = fields.exists(k) ? fields.get(k) : fields.get(k + "_");
				switch (Type.typeof(Reflect.field(this, field)))
				{
					case ValueType.TInt:    v = Std.parseInt(v);
					case ValueType.TFloat:  v = Std.parseFloat(v);
					case ValueType.TBool:   v = Std.bool(v);
					default:                // nothing to do
				}
				Reflect.setField(this, field, v);
			}
		}
	}
	
	function createChildComponents()
	{
		if (innerNode != null)
		{
			innerComponents = manager.createDocComponents(parent, innerNode, true);
		}
		
		if (doc != null)
		{
			manager.createDocComponents(this, doc, false);
		}
	}

    public function render() : String
    {
		if (!visible)
		{
			for (child in innerComponents)
			{
				child.visible = false;
			}
			
			return "";
		}
        
		if (Lib.config.isTraceComponent) trace("render " + fullID);
		
		HaqComponentTools.expandDocElemIDs(prefixID, doc);
		if (parent != null && innerNode != null)
		{
			HaqComponentTools.expandDocElemIDs(parent.prefixID, innerNode);
		}
		
		for (child in innerComponents)
		{
			child.innerNode.parent.replaceChild(child.innerNode, new HtmlNodeText(child.render()));
		}
		
		for (child in components)
		{
			if (!child.isInnerComponent)
			{
				Lib.assert(child != null);
				Lib.assert(child.innerNode != null);
				Lib.assert(child.innerNode.parent != null);
				child.innerNode.parent.replaceChild(child.innerNode, new HtmlNodeText(child.render()));
			}
		}
		
		var text = doc.innerHTML;
		if (innerNode != null)
		{
			var reInnerContent = new EReg("<innercontent\\s*[/]?>", "i");
			text = reInnerContent.replace(text, innerNode.innerHTML);
		}
		
		return text.trim(" \t\r\n");
    }

    /**
     * Like $ в jQuery. Select DOM nodes from this component's DOM tree.
     * @param query CSS selector.
     */
    public function q(?query:Dynamic=null) : HaqQuery
    {
		if (Type.getClass(query) == haquery.server.HaqQuery)
		{
			return query;
		}
		
		var cssGlobalizer = new HaqCssGlobalizer(fullTag);
		
		if (query == null)
		{
			return new HaqQuery(this, cssGlobalizer, '', null);
		}
        
		
		if (Type.getClass(query) == HtmlNodeElement)
		{
			Lib.assert(!page.isPostback, "Calling of the HaqComponent.q() with HtmlNodeElement parameter do not possible on the postback.");
			return new HaqQuery(this, cssGlobalizer, "", [ query ]);
		}
		
		if (Type.getClass(query) == Array)
		{
			Lib.assert(!page.isPostback, "Calling of the HaqComponent.q() with Array parameter do not possible on the postback.");
			return new HaqQuery(this, cssGlobalizer, "", query);
		}
        
		if (Type.getClass(query) == String)
		{
			
			var nodes = doc.find(cssGlobalizer.selector(query));
			return new HaqQuery(this, cssGlobalizer, query, nodes);
		}
        
		throw new Exception("HaqComponent.q() error - 'query' parameter must be a String, HaqQuery or HtmlNodeElement.");
    }
	
	/**
	 * Delayed call client method, marked as @shared.
	 */
	public function callSharedMethod(method:String, ?params:Array<Dynamic>) : Void
	{
		Lib.assert(page.isPostback, "HaqComponent.callSharedMethod() allowed on the postback only.");
        
        Lib.addAjaxResponse(
			  "haquery.client.Lib.page." + (fullID != "" ? "findComponent('" + fullID + "')." : "") + method
			+ "(" + Lambda.map(params != null ? params : [], function(p) return "haxe.Unserializer.run('" + Serializer.run(p) + "')").join(",") + ');'
		);
	}
	
	public function callElemEventHandler(elemID:String, eventName:String) : Dynamic
    {
		var handler = elemID + '_' + eventName;
		
		try
		{
			return Reflect.callMethod(this, Reflect.field(this, handler), [ this, null ]);
		}
		catch (e:String)
		{
			if (e == "Invalid call")
			{
				throw new Exception("Invalid call: " + Type.getClassName(Type.getClass(this)) + "." + handler + "(t, e).", e);
			}
			Exception.rethrow(e);
			return null;
		}
    }
    
	/**
	 * Tells HaQuery to load JS file from support component folder.
	 * @param	url Url to js file (global or related to support component folder).
	 * @example registerScript('myscript.js'); // assert file in support component folder
	 * @example registerScript('/scripts/myscript.js'); // site url
	 * @example registerScript('http://google.com/scripts/theirscript.js'); // global url
	 * @example registerScript('<script>alert("OK");</script>'); // html block
	 */
	function registerScript(url:String)
	{
		manager.registerScript(fullTag, url);
	}
	
	/**
	 * Tells HaQuery to load CSS file from support component folder.
	 * @param	url Url to css file (global or related to support component folder).
	 */
	function registerStyle(url:String)
	{
		manager.registerStyle(fullTag, url);
	}
	
	function getSupportPath() : String
	{
		return manager.get(fullTag).getSupportFilePath("");
	}
	
	/**
	 * Search for file (can search in "support" folders if relpath starts with "~/").
	 * @param	relpath File name or path (can starts with "~/").
	 * @return	Path to finded file or null if file not found.
	 */
	function resolveFilePath(relpath:String) : String
	{
		if (relpath.startsWith("~/"))
		{
			relpath = manager.get(fullTag).getSupportFilePath(relpath.substr(2));
		}
		else
		{
			if (!FileSystem.exists(relpath))
			{
				relpath = null;
			}
		}
		return relpath;
	}
}
