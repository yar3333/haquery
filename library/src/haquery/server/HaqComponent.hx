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
    private var parentNode : HaqXmlNodeElement;

    /**
     * template.html as DOM tree.
     */
    private var doc : HaqXml;

	/**
	 * Equivalent to Lib.isPostback.
	 */
    public var isPostback : Bool;
    
    /**
     * Need render?
     */
    public var visible : Bool;
	
    public function new() : Void
	{
		super();
        isPostback = Lib.isPostback;
		visible = true;
	}
    
    public function construct(manager:HaqComponentManager, parent: HaqComponent, tag:String, id:String, doc: HaqXml, params:Hash<String>, parentNode:HaqXmlNodeElement) : Void
    {
		super.commonConstruct(parent, tag, id);
        
		this.manager = manager;
        this.doc = doc;
        this.parentNode = parentNode;
		
		loadParamsToObjectFields(params, getFieldsToLoadParams());
        createEvents();
        createChildComponents();
		
        if (Reflect.isFunction(Reflect.field(this, 'init')))
        {
            Reflect.callMethod(this, Reflect.field(this, 'init'), []);
        }
    }
    
    function getFieldsToLoadParams() :  Hash<String>
    {
        var restrictedFields : Array<String> = Reflect.fields(Type.createEmptyInstance(Type.resolveClass('haquery.server.HaqComponent')));
        var r : Hash<String> = new Hash<String>(); // fieldname => FieldName
        for (field in Reflect.fields(this))
        {
            if (!Reflect.isFunction(Reflect.field(this, field))
             && !Lambda.has(restrictedFields, field)
             && !field.startsWith('event_')
            ) {
                r.set(field.toLowerCase(), field);
            }
        }
        return r;
    }
	
	function loadParamsToObjectFields(params:Hash<String>, fields:Hash<String>) : Void
	{
        if (params!=null)
        {
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
	}
	
	function createChildComponents() : Void
	{
		if (doc != null) createChildComponents_inner(doc);
	}
	
	function createChildComponents_inner(baseNode:HaqXmlNodeElement) : Void
    {
		var i = 0;
		while (i < untyped __call__('count', baseNode.children))
        {
			var node : HaqXmlNodeElement = baseNode.children[i];
			Lib.assert(node.name!='haq:placeholder');
			Lib.assert(node.name!='haq:content');
            
            createChildComponents_inner(node);
            
            if (node.name.startsWith('haq:'))
            {
                node.component = manager.createComponent(this, node.name, node.getAttribute('id'), Lib.hashOfAssociativeArray(node.getAttributesAssoc()), node);
            }
			i++;
        }
    }

    function prepareDocToRender(baseNode:HaqXmlNodeElement) : Void
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
                    prepareDocToRender(node);
                    
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
                prepareDocToRender(node);
                var nodeID = node.getAttribute('id');
                if (nodeID!=null && nodeID!='') node.setAttribute('id', this.prefixID + nodeID);
                if (node.name=='label')
                {
                    var nodeFor = node.getAttribute('for');
                    if (nodeFor!=null && nodeFor!='') 
                        node.setAttribute('for', this.prefixID + nodeFor);
                }
            }
			
			i++;
        }
    }

    public function render() : String
    {
        if (Lib.config.isTraceComponent) trace("render " + this.fullID);
		
		prepareDocToRender(doc);

        var r = doc.toString().trim("\r\n");
        return r;
    }

    /**
     * Like $ в jQuery. Select DOM nodes from this component's DOM tree.
     * @param query CSS selector.
     */
    public function q(?query:Dynamic=null) : HaqQuery
    {
        if (query==null) return new HaqQuery(this.prefixID, '', null);
        if (Type.getClassName(Type.getClass(query))=='HaqQuery') return query;
        if (Type.getClassName(Type.getClass(query))!='String') throw "HaqComponent.q() error - 'query' parameter must be a string or HaqQuery.";
        
        var nodes = this.doc.find(query);
        
        return new HaqQuery(this.prefixID, query, nodes);
    }

    function callClientMethod(method:String, ?params:Array<Dynamic>) : Void
    {
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
}
