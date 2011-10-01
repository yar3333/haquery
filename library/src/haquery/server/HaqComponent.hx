package haquery.server;

import php.Lib;
import haquery.server.HaqXml;
using haquery.StringTools;

class HaqComponent extends haquery.base.HaqComponent
{
    var manager : HaqComponentManager;
    
    /**
     * HTML between component's open and close tags (where component inserted).
     */
    private var innerHTML : String;

    /**
     * template.html as DOM tree.
     */
    private var doc : HaqXml;

    /**
     * Need render?
     */
    public var visible : Bool;
    
	/**
	 * Params, which must be loaded to object variables.
	 */
    private var params : Dynamic;

	public function new() : Void
	{
		super();
		visible = true;
	}

	public function construct(manager:HaqComponentManager, parent: HaqComponent, tag:String, id:String, doc: HaqXml, params:Dynamic, innerHTML:String) : Void
    {
		super.commonConstruct(parent, tag, id);
        
		this.manager = manager;
        this.doc = doc;
		this.params = params;
        this.innerHTML = innerHTML;
		
		loadParamsToObjectFields();
		createEvents();
        createChildComponents();
		
        if (Reflect.isFunction(Reflect.field(this, 'init')))
        {
            Reflect.callMethod(this, Reflect.field(this, 'init'), []);
        }
    }
	
	private function loadParamsToObjectFields() : Void
	{
        if (params!=null)
        {
			var restrictedFields : Array<String> = Reflect.fields(Type.createEmptyInstance(Type.resolveClass('haquery.server.HaqComponent')));
			var fields : Hash<String> = new Hash<String>(); // fieldname => FieldName
			for (field in Reflect.fields(this))
			{
				if (!Reflect.isFunction(Reflect.field(this, field))
                 && !Lambda.has(restrictedFields, field)
				 && !field.startsWith('event_')
				) fields.set(field.toLowerCase(), field);
			}
            
			if (Type.getClassName(Type.getClass(params)) == 'Hash')
            {
                var paramsAsHash : Hash<String> = cast params;
                for (k in paramsAsHash.keys())
                {
                    var v = paramsAsHash.get(k);
                    k = k.toLowerCase();
                    if (fields.exists(k))
                    {
                        var field = fields.get(k);
                        Reflect.setField(this, field, v);
                    }
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
			HaQuery.assert(node.name!='haq:placeholder');
			HaQuery.assert(node.name!='haq:content');
            if (node.name.startsWith('haq:'))
            {
                node.component = manager.createComponent(this, node.name, node.getAttribute('id'), Lib.hashOfAssociativeArray(node.getAttributesAssoc()), node.innerHTML);
            }
            else
			{
                createChildComponents_inner(node);
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
                if (node.component!=null)
                {
                    if (node.component.visible)
                    {
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
        if (HaQuery.config.isTraceComponent) trace("render " + this.fullID);
		
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
