package haquery.server;

import haquery.server.HaqXml;
import haquery.server.Lib;
import haquery.Std;
import Type;

using haquery.StringTools;

class HaqComponent extends haquery.base.HaqComponent
{
    var manager : HaqComponentManager;
    
    /**
     * HTML between component's open and close tags (where component inserted).
     */
    var parentNode : HaqXmlNodeElement;

    /**
     * template.html as DOM tree.
     */
    var doc : HaqXml;
    
    /**
     * Need render?
     */
    public var visible : Bool;
	
    public function new() : Void
	{
		super();
		visible = true;
	}
    
    public function construct(manager:HaqComponentManager, fullTag:String, parent:HaqComponent, id:String, doc:HaqXml, params:Hash<String>, parentNode:HaqXmlNodeElement) : Void
    {
		super.commonConstruct(fullTag, parent, componentTemplate, id);
        
		this.manager = manager;
        this.doc = doc;
        this.parentNode = parentNode;
		
		// loading params to object fields
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
		var fields = manager.getFieldsToLoadParams(this);
		
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
		if (doc != null) manager.createChildComponents(this, doc);
	}

    public function render() : String
    {
        if (Lib.config.isTraceComponent) trace("render " + fullID);
		
		manager.prepareDocToRender(prefixID, doc);

        var r = doc.toString().trim("\r\n");
        return r;
    }

    /**
     * Like $ в jQuery. Select DOM nodes from this component's DOM tree.
     * @param query CSS selector.
     */
    public function q(?query:Dynamic=null) : HaqQuery
    {
        var prefixCssClass = fullTag != "" ? fullTag.replace(".", "_") + HaqDefines.DELIMITER : "";
		
		if (query == null) return new HaqQuery(prefixCssClass, prefixID, '', null);
        if (Type.getClass(query) == haquery.server.HaqQuery) return query;
		if (Type.getClass(query) ==  HaqXmlNodeElement)
		{
			Lib.assert(!Lib.isPostback, "Calling of the HaqComponent.q() with HaqXmlNodeElement parameter do not possible on the postback.");
			return new HaqQuery(prefixCssClass, prefixID, "", [ query ]);
		}
        if (Type.getClassName(Type.getClass(query)) != 'String')
		{
			throw "HaqComponent.q() error - 'query' parameter must be a string or HaqQuery.";
		}
        
        var nodes = doc.find(query);
        
        return new HaqQuery(prefixCssClass, prefixID, query, nodes);
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
        
        HaqInternals.addAjaxResponse(HaqTools.getCallClientFunctionString(funcName, params) + ';');
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
        
        HaqInternals.addAjaxResponse(HaqTools.getCallClientFunctionString(funcName, params) + ';');
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
		manager.registerScript(componentTemplate, url);
	}
	
	/**
	 * Tells HaQuery to load CSS file from support component folder.
	 * @param	url Url to css file (global or related to support component folder).
	 */
	function registerStyle(url:String)
	{
		manager.registerStyle(componentTemplate, url);
	}
}
