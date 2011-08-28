package haquery.server;

import haquery.server.HaqQuery;
import haquery.server.HaQuery;
import haquery.server.HaqXml;
import php.Lib;

/**
 * Базовый класс для компонентов и страниц.
 */
class HaqComponent extends haquery.base.HaqComponent<HaqComponent>
{
    var manager : HaqComponentManager;
    
    /**
     * То, что было задано между открытием и закрытием тега компонента.
     */
    private var innerHTML : String;

    /**
     * HTML-документ компонента.
     */
    private var doc : HaqXml;

    /**
     * Рендерить ли компонент в HTML.
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
		if (Reflect.hasMethod(this, 'init')) Reflect.callMethod(this, Reflect.field(this, 'init'), []);
    }
	
	private function loadParamsToObjectFields() : Void
	{
        if (params!=null)
        {
			var restrictedFields : Array<String> = Reflect.fields(Type.createEmptyInstance(Type.resolveClass('haquery.server.HaqComponent')));
			var fields : Hash<String> = new Hash<String>(); // названиеполя => НазваниеПоля
			for (field in Reflect.publicVars(this))
			{
				if (restrictedFields.indexOf(field) == -1 
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
                    var text = node.component.render().trim();
                    var prev = node.getPrevSiblingNode();
                    
                    //if (untyped __php__("$prev instanceof HaqXmlNodeText"))
                    if (Reflect.isInstanceOf(prev, 'HaqXmlNodeText'))
					{
						var re : EReg = new EReg('(?:^|\n)([ ]+)$', 's');
						if (re.match(cast(prev, HaqXmlNodeText).text))
						{
							text = text.replace("\n", "\n"+re.matched(1));
						}
					}
                    node.parent.replaceChild(node, new HaqXmlNodeText(text));
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

    /**
     * Возвращает конечный HTML-код компонента.
     * Иногда может перегружаться для хитрых компонентов (например, для компонента list).
     * @return string 
     */
    public function render() : String
    {
        if (HaQuery.config.isTraceComponent) trace("render " + this.fullID);
		
		prepareDocToRender(doc);

        var r = doc.toString().trim("\r\n");
        return r;
    }

    /**
     * Аналог $ в jQuery. Выбирает элементы DOM в документе данного компонента.
     * @param string $query Строка выбора узлов DOM (как в jQuery).
     * @param bool $isSystem Этот параметр системный. Если установить в true, то действия над элементами не будут передаваться клиенту при ajax-запросах.
     * @return HaqQuery
     */
    public function q(?query:Dynamic=null) : HaqQuery
    {
        if (query==null) return new HaqQuery(this.prefixID, '', null);
        if (Type.getClassName(Type.getClass(query))=='HaqQuery') return query;
        if (Type.getClassName(Type.getClass(query))!='String') throw "HaqComponent.q() error - 'query' parameter must be a string or HaqQuery.";
        
        var nodes = this.doc.find(query);
        
        return new HaqQuery(this.prefixID, query, nodes);
    }

    function callClientMethod(method:String, params:Array<Dynamic>) : Void
    {
		var funcName = this.fullID.length != 0
			? "haquery.client.HaQuery.page.findComponent('" + fullID + "')." + method
			: "haquery.client.HaQuery.page." + method;
		
		HaqInternals.addAjaxAnswer(HaqTools.getCallClientFunctionString(funcName, params) + ';');
    }
}
