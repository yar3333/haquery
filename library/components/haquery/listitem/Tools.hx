package components.haquery.listitem;

class Tools
{
	public static function applyHtmlParams(html:String, params:Dynamic) : String
	{
		if (params == null || html.indexOf("{") < 0) return html;
		
		var r = new StringBuf();
		var i = 0;
		while (i < html.length)
		{
			var start = html.indexOf("{", i);
			if (start < 0) { r.addSub(html, i); break; }
			var end = html.indexOf("}", i);
			if (end < 0) { r.addSub(html, i); break; }
			
			r.addSub(html, i, start - i);
			
			var param = html.substring(start + 1, end);
			
			var obj = params;
			var n : Int;
			while (obj != null && (n = param.indexOf(".")) >= 0)
			{
				obj = getHtmlParamValue(obj, param.substr(0, n));
				param = param.substr(n + 1);
			}
			if (obj != null)
			{
				r.add(getHtmlParamValue(obj, param));
			}
			else
			{
				r.addSub(html, i, end - start);
			}
			
			i = end + 1;
		}
		return r.toString();
	}
	
	static function getHtmlParamValue(params:Dynamic, param:String) : String
	{
		if (Reflect.isFunction(Reflect.field(params, "get_" + param)))
		{
			return Reflect.callMethod(params, Reflect.field(params, "get_" + param), []);
		}
		else
		if (Reflect.hasField(params, param))
		{
			return Reflect.field(params, param);
		}
		return null;
	}
}
