package haquery.server;

import haquery.Exception;
import haxe.htmlparser.HtmlNodeElement;
import haquery.common.HaqDefines;
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
	
	public static function callMethod(component:HaqComponent, method:String, params:Dynamic) : Dynamic
	{
		var result : Dynamic = null;
		
		var r = callElemEventHandler(component, method);
		if (!r.success)
		{
			r = callSharedMethod(component, method, params);
		}
		if (r.success)
		{
			result = r.result;
		}
		else
		{
			throw new Exception("Method " + component.fullTag + ".Server." + method + "() must exists and marked with '@shared' to be callable from the client.");
		}
        
        return result;
	}
	
	static function callElemEventHandler(component:HaqComponent, method:String) : { success:Bool, result:Dynamic }
	{
		var n = method.lastIndexOf("_");
		if (n >= 0)
		{
			var event = method.substr(n + 1);
			if (Lambda.has(HaqDefines.elemEventNames, event))
			{
				return { success:true, result:component.callElemEventHandler(method.substr(0, n), event) };
			}
		}
		return { success:false, result:null };
	}
	
	static function callSharedMethod(component:HaqComponent, method:String, params:Array<Dynamic>) : { success:Bool, result:Dynamic }
	{
		if (isMethodShared(Type.getClass(component), method))
		{
			var f = Reflect.field(component, method);
			return { success:true, result:Reflect.callMethod(component, f, params != null ? params : []) };
		}
		return { success:false, result:null };
	}
	
	static function isMethodShared(cls:Class<HaqComponent>, method:String) : Bool
	{
		if (cls != null)
		{
			var meta = haxe.rtti.Meta.getFields(cls);
			var m = Reflect.field(meta, method);
			if (Reflect.hasField(m, "shared"))
			{
				return true;
			}
			return isMethodShared(cast Type.getSuperClass(cls), method);
		}
		return false;
	}
	
	public static function fillTagIDs(component:HaqComponent, destTagIDs:Hash<Array<String>>) : Hash<Array<String>>
	{
		if (component.visible)
		{
			if (!destTagIDs.exists(component.fullTag))
			{
				destTagIDs.set(component.fullTag, []);
			}
			destTagIDs.get(component.fullTag).push(component.fullID);
			
			for (child in component.components)
			{
				fillTagIDs(child, destTagIDs);
			}
		}
		
		return destTagIDs;
	}
}