package haquery.server;

import haquery.Std;
import haquery.server.HaqCssGlobalizer;
import haquery.server.HaqXml;
import haquery.server.Lib;
import haquery.server.HaqComponentTools;

using haquery.StringTools;

class HaqComponent extends haquery.base.HaqComponent
{
    /**
     * HTML between component's open and close tags (where component inserted).
     */
    public var parentNode(default, null) : HaqXmlNodeElement;

    /**
     * template.html as DOM tree.
     */
    public var doc(default, null) : HaqXml;
    
    /**
     * Need render?
     */
    public var visible : Bool;
	
	/**
	 * If true, then parent must skip this component on render (component will be rendered by another component).
	 */
	public var isCustomRender(default, null) : Bool;
	
    /**
     * These components must rendered by this component.
     */
	var customRenderComponents : Array<HaqComponent>;
	
    public function new() : Void
	{
		super();
		visible = true;
	}
    
    public function construct(manager:HaqTemplateManager, fullTag:String, parent:HaqComponent, id:String, doc:HaqXml, params:Hash<String>, parentNode:HaqXmlNodeElement, isCustomRender:Bool) : Void
    {
		super.commonConstruct(manager, fullTag, parent, id);
        
        this.doc = doc;
        this.parentNode = parentNode;
		this.isCustomRender = isCustomRender;
		
		if (params != null)
		{
			loadFieldValues(params);
		}
        
		createEvents();
        createChildComponents();
		
        if (Reflect.isFunction(Reflect.field(this, 'init')))
        {
            Reflect.callMethod(this, Reflect.field(this, 'init'), []);
        }
    }
	
	function loadFieldValues(params:Hash<String>) : Void
	{
		var fields = HaqComponentTools.getFieldsToLoadParams(this);
		
		for (k in params.keys())
		{
			var v : Dynamic = params.get(k);
			k = k.toLowerCase();
			if (fields.exists(k))
			{
				var field = fields.get(k);
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
		if (parentNode != null)
		{
			customRenderComponents = manager.createDocComponents(parent, parentNode, true);
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
			for (child in customRenderComponents)
			{
				child.visible = false;
			}
			
			return "";
		}
        
		if (Lib.config.isTraceComponent) trace("render " + fullID);
		
		HaqComponentTools.expandDocElemIDs(prefixID, doc);
		if (parent != null && parentNode != null)
		{
			HaqComponentTools.expandDocElemIDs(parent.prefixID, parentNode);
		}
		
		for (child in customRenderComponents)
		{
			child.parentNode.parent.replaceChild(child.parentNode, new HaqXmlNodeText(child.render()));
		}
		
		for (child in components)
		{
			if (!isCustomRender)
			{
				child.parentNode.parent.replaceChild(child.parentNode, new HaqXmlNodeText(child.render()));
			}
		}
		
		var text = doc.innerHTML.replace("{content}", parentNode.innerHTML).trim(" \t\r\n");
		
		return text;
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
			return new HaqQuery(cssGlobalizer, prefixID, '', null);
		}
        
		
		if (Type.getClass(query) == HaqXmlNodeElement)
		{
			Lib.assert(!Lib.isPostback, "Calling of the HaqComponent.q() with HaqXmlNodeElement parameter do not possible on the postback.");
			return new HaqQuery(cssGlobalizer, prefixID, "", [ query ]);
		}
		
		if (Type.getClass(query) == Array)
		{
			Lib.assert(!Lib.isPostback, "Calling of the HaqComponent.q() with Array parameter do not possible on the postback.");
			return new HaqQuery(cssGlobalizer, prefixID, "", query);
		}
        
		if (Type.getClass(query) == String)
		{
			
			var nodes = doc.find(cssGlobalizer.selector(query));
			return new HaqQuery(cssGlobalizer, prefixID, query, nodes);
		}
        
		throw "HaqComponent.q() error - 'query' parameter must be a String, HaqQuery or HaqXmlNodeElement.";
    }

    /**
	 * Later call of the client method.
     * @deprecated Use callSharedMethod() instead.
     */
	function callClientMethod(method:String, ?params:Array<Dynamic>) : Void
    {
		Lib.assert(Lib.isPostback, "HaqComponent.callClientMethod() allowed on the postback only.");
        
        var funcName = fullID.length != 0
            ? "haquery.client.HaqSystem.page.findComponent('" + fullID + "')." + method
            : "haquery.client.HaqSystem.page." + method;
        
        HaqSystem.addAjaxResponse(HaqTools.getCallClientFunctionString(funcName, params) + ';');
    }
	
	/**
	 * Delayed call client method, marked as @shared.
	 */
	function callSharedMethod(method:String, ?params:Array<Dynamic>) : Void
	{
		Lib.assert(Lib.isPostback, "HaqComponent.callSharedMethod() allowed on the postback only.");
        
        var funcName = fullID.length != 0
            ? "haquery.client.HaqSystem.page.findComponent('" + fullID + "')." + method
            : "haquery.client.HaqSystem.page." + method;
        
        HaqSystem.addAjaxResponse(HaqTools.getCallClientFunctionString(funcName, params) + ';');
	}
    
    public function callElemEventHandler(elemID:String, eventName:String) : Dynamic
    {
        var handler = elemID + '_' + eventName;
        return Reflect.callMethod(this, handler, [ this ]);
    }
    
    /*function getSupportPath() : String
    {
        return manager.getSupportPath(tag);
    }*/
	
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
		manager.registerScript(fullID, url);
	}
	
	/**
	 * Tells HaQuery to load CSS file from support component folder.
	 * @param	url Url to css file (global or related to support component folder).
	 */
	function registerStyle(url:String)
	{
		manager.registerStyle(fullID, url);
	}
	
	function getSupportPath()
	{
		return manager.templates.get(fullTag).getSupportFilePath("");
	}
}
