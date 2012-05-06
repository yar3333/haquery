package haquery.server;

import haxe.htmlparser.HtmlNodeElement;

using haquery.StringTools;

class HaqComponentTools 
{
    static var baseComponentFields : Array<String> = null;
	
	public static function getFieldsToLoadParams(component:HaqComponent) : Hash<String>
    {
		if (baseComponentFields == null)
		{
			baseComponentFields = Type.getInstanceFields(HaqComponent);
			baseComponentFields.push('template');
		}
		
		var r : Hash<String> = new Hash<String>(); // fieldname => FieldName
        for (field in Type.getInstanceFields(Type.getClass(component)))
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
	
	public static function expandDocElemIDs(prefixID:String, baseNode:HtmlNodeElement) : Void
    {
		for (node in baseNode.children)
        {
            if (!node.name.startsWith('haq:'))
            {
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
				
                expandDocElemIDs(prefixID, node);
            }
        }
    }
}