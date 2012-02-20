package haquery.server;

import haquery.server.HaqXml;

using haquery.StringTools;

class HaqComponentTools 
{
    static var baseComponentFields : List<String> = null;
	
	static function __init__() : Void
	{
		var emptyComponent = Type.createEmptyInstance(HaqComponent);
		baseComponentFields = Lambda.filter(
			 Reflect.fields(emptyComponent)
			,function(field) return !Reflect.isFunction(Reflect.field(emptyComponent, field))
		);
		baseComponentFields.push('template');
	}
	
	public static function getFieldsToLoadParams(component:HaqComponent) : Hash<String>
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
	
	public static function prepareDocToRender(component:HaqComponent, baseNode:HaqXmlNodeElement) : Void
    {
		var i = 0;
		while (i < baseNode.children.length)
        {
            var node = baseNode.children[i];
            if (node.name.startsWith('haq:'))
            {
                if (node.component == null)
                {
                    trace("Component is null: " + node.name);
                    Lib.assert(false);
                }
                
                if (node.component.visible)
                {
                    prepareDocToRender(component, node);
                    
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
                prepareDocToRender(component, node);
                var nodeID = node.getAttribute('id');
                if (nodeID != null && nodeID != '')
				{
					node.setAttribute('id', component.prefixID + nodeID);
				}
                if (node.name == 'label')
                {
                    var nodeFor = node.getAttribute('for');
                    if (nodeFor != null && nodeFor != '')
					{
						node.setAttribute('for', component.prefixID + nodeFor);
					}
                }
            }
			
			i++;
        }
    }
}