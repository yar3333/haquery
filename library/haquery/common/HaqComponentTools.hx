package haquery.common;

import haxe.ds.StringMap;
import htmlparser.HtmlNodeElement;
import stdlib.Exception;
import stdlib.Debug;
using stdlib.StringTools;

#if server
import haquery.server.HaqComponent;
#else
import haquery.client.HaqComponent;
#end

class HaqComponentTools
{
	public static function getTemplateClass(componentClass:Class<Dynamic>) : Class<Dynamic>
	{
		if (componentClass == null) return null;
		
		var className = Type.getClassName(componentClass);
		var n = className.lastIndexOf(".");
		if (n > 0)
		{
			#if !client
			var templateClassName = className.substr(0, n) + ".TemplateServer";
			#else
			var templateClassName = className.substr(0, n) + ".TemplateClient";
			#end
			var templateClass = Type.resolveClass(templateClassName);
			if (templateClass != null)
			{
				return templateClass;
			}
			else
			{
				return getTemplateClass(Type.getSuperClass(componentClass));
			}
		}
		
		return null;
	}
	
	public static function htmlTagToFullTag(htmlTag:String) : String
	{
		return HaqDefines.folders.components + "." + StringTools.replace(htmlTag, "-", ".");
	}
	
	public static function fullTagToHtmlTag(fullTag:String) : String
	{
		return StringTools.replace(fullTag.substr(HaqDefines.folders.components.length + 1), ".", "-");
	}
	
	public static function callMethod(component:HaqComponent, method:String, params:Dynamic, ?metaMark:String) : Dynamic
	{
		var result : Dynamic = null;
		
		var r = callElemEventHandler(component, method);
		if (!r.success)
		{
			r = callMetaMarkedMethod(metaMark, component, method, params);
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
	
	static function callMetaMarkedMethod(metaMark:String, component:HaqComponent, method:String, params:Array<Dynamic>) : { success:Bool, result:Dynamic }
	{
		if (isMethodMetaMarked(metaMark, Type.getClass(component), method))
		{
			var f = Reflect.field(component, method);
			return { success:true, result:Reflect.callMethod(component, f, params != null ? params : []) };
		}
		return { success:false, result:null };
	}
	
	static function isMethodMetaMarked(metaMark:String, clas:Class<HaqComponent>, method:String) : Bool
	{
		if (clas == null) return false;
		if (metaMark == null || metaMark == "") return true;
		var meta = haxe.rtti.Meta.getFields(clas);
		var m = Reflect.field(meta, method);
		return Reflect.hasField(m, metaMark) ? true : isMethodMetaMarked(metaMark, cast Type.getSuperClass(clas), method);
	}
	
	
	#if server
	
    static var baseComponentFields : Array<String> = null;
	
	static var fieldNamesToLoadParamsCache = new Map<String, Map<String, String>>();
	
	public static function getFieldNamesToLoadParams(component:HaqComponent) : Map<String,String>
    {
		if (fieldNamesToLoadParamsCache.exists(component.fullTag)) return fieldNamesToLoadParamsCache.get(component.fullTag);
		
		if (baseComponentFields == null)
		{
			baseComponentFields = Type.getInstanceFields(HaqComponent);
			baseComponentFields.push('template');
		}
		
		var r = new Map<String,String>(); // fieldname => FieldName
        for (field in Type.getInstanceFields(Type.getClass(component)))
        {
            if (!Reflect.isFunction(Reflect.field(component, field))
			 && (field == 'visible' || !Lambda.has(baseComponentFields, field))
             && !field.startsWith('event_')
            ) {
                r.set(field.toLowerCase(), field);
            }
        }
		
		fieldNamesToLoadParamsCache.set(component.fullTag, r);
		
		return r;
    }
	
	public static function getParamNames(params:Dynamic) : Map<String,String>
	{
		var r = new Map<String,String>(); // fieldname => FieldName
        
		var cls = Type.getClass(params);
		for (param in (cls != null ? Type.getInstanceFields(cls) : Reflect.fields(params)))
        {
			r.set(param.toLowerCase(), param);
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
                if (nodeID != null && nodeID != '' && nodeID.indexOf(":") == -1)
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
	
	public static function fillTagIDs(component:HaqComponent, destTagIDs:StringMap<Array<String>>) : StringMap<Array<String>>
	{
		if (component.visible)
		{
			if (!destTagIDs.exists(component.fullTag)) destTagIDs.set(component.fullTag, []);
			destTagIDs.get(component.fullTag).push(component.fullID);
			for (child in component.components) fillTagIDs(child, destTagIDs);
		}
		return destTagIDs;
	}
	
	public static function getFullUrl(fullTag:String, url:String) : String
	{
		if (url.startsWith("~/"))
		{
			url = url.substr(2);
		}
		
		if (fullTag != null && url.indexOf("://") < 0 && !url.startsWith("/") && !url.startsWith("<"))
		{
			var template = haquery.server.Lib.manager.get(fullTag);
			Debug.assert(template != null, "Template '" + fullTag + "' not found.");
			url = template.getSupportFilePath(url);
		}
		
		return url;
	}
	
	#end
}
