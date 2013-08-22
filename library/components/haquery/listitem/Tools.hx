package components.haquery.listitem;

import haxe.htmlparser.HtmlDocument;

class Tools
{
    @:isVar static var reHtmlParam(get_reHtmlParam, null) : EReg;
	static function get_reHtmlParam()
	{
		if (reHtmlParam == null)
		{
			reHtmlParam = new EReg("[{]([_a-z][_a-z0-9]*)[}]", "i");
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
                if (Reflect.isFunction(Reflect.field(params, "get_" + param)))
                {
					return Std.string(Reflect.callMethod(params, Reflect.field(params, "get_" + param), []));
				}
				else
                if (Reflect.hasField(params, param))
                {
					return Std.string(Reflect.field(params, param));
                }
                return re.matched(0);
            });
        }
        return html;
    }
}
