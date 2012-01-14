package haquery.server;

import haquery.server.HaqXml;
import haquery.server.Lib;
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
    
    public function construct(manager:HaqComponentManager, parent:HaqComponent, tag:String, id:String, doc:HaqXml, params:Hash<String>, parentNode:HaqXmlNodeElement) : Void
    {
		super.commonConstruct(parent, tag, id);
        
		this.manager = manager;
        this.doc = doc;
        this.parentNode = parentNode;
		
		// loading params to object fields
        if (params != null)
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
                        case ValueType.TBool:   v = HaqTools.bool(v);
                        default:                // nothing to do
                    }
                    Reflect.setField(this, field, v);
                }
            }
        }
        
		createEvents();
        createChildComponents();
		
        if (Reflect.isFunction(Reflect.field(this, 'init')))
        {
            Reflect.callMethod(this, Reflect.field(this, 'init'), []);
        }
    }
	
	function createChildComponents()
	{
		if (doc != null) manager.createChildComponents(this, doc);
	}

    public function render() : String
    {
        if (Lib.config.isTraceComponent) trace("render " + this.fullID);
		
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
        if (query == null) return new HaqQuery(this.prefixID, '', null);
        if (Type.getClass(query) == haquery.server.HaqQuery) return query;
		if (untyped __php__("$query instanceof HaqXmlNodeElement"))
		{
			Lib.assert(!Lib.isPostback, "Calling of the HaqComponent.q() with HaqXmlNodeElement parameter do not possible on the postback.");
			return new HaqQuery(this.prefixID, "", Lib.toPhpArray([ query ]));
		}
        if (Type.getClassName(Type.getClass(query)) != 'String')
		{
			throw "HaqComponent.q() error - 'query' parameter must be a string or HaqQuery.";
		}
        
        var nodes = this.doc.find(query);
        
        return new HaqQuery(this.prefixID, query, nodes);
    }

    function callClientMethod(method:String, ?params:Array<Dynamic>) : Void
    {
		Lib.assert(Lib.isPostback, "HaqComponent.callClientMethod() allowed on the postback only.");
        
        var funcName = this.fullID.length != 0
            ? "haquery.client.HaqSystem.page.findComponent('" + fullID + "')." + method
            : "haquery.client.HaqSystem.page." + method;
        
        HaqInternals.addAjaxResponse(HaqTools.getCallClientFunctionString(funcName, params) + ';');
    }
    
    public function callElemEventHandler(elemID:String, eventName:String) : Void
    {
        var handler = elemID + '_' + eventName;
        Reflect.callMethod(this, handler, [ this ]);
    }
    
    function getSupportPath():String
    {
        return manager.getSupportPath(tag);
    }
	
	/**
	 * Tells HaQuery to load JS file from support component folder.
	 * @param	url Url to js file (global or related to support component folder).
	 */
	function registerScript(url:String)
	{
		manager.registerScript(tag, url);
	}
	
	/**
	 * Tells HaQuery to load CSS file from support component folder.
	 * @param	url Url to css file (global or related to support component folder).
	 */
	function registerStyle(url:String)
	{
		manager.registerStyle(tag, url);
	}
}
