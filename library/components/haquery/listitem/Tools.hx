package components.haquery.listitem;

class Tools
{
    @:isVar static var reHtmlParam(get_reHtmlParam, null) : EReg;
	static function get_reHtmlParam()
	{
		if (reHtmlParam == null)
		{
			reHtmlParam = new EReg("[{]([_a-z][_a-z0-9]*(?:[.][_a-z][_a-z0-9]*)*)[}]", "ig");
		}
		return reHtmlParam;
	}
	
	static public function applyHtmlParams(html:String, params:Dynamic) : String
    {
        if (params != null)
		{
            html = reHtmlParam.map(html, function(re) 
            {
                var param = re.matched(1);
				var obj = params;
				var n : Int;
				while (obj != null && (n = param.indexOf(".")) >= 0)
				{
					obj = getHtmlParamValue(obj, param.substr(0, n));
					param = param.substr(n + 1);
				}
                return obj != null ? getHtmlParamValue(obj, param) : re.matched(0);
            });
        }
        return html;
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
