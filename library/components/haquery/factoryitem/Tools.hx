package components.haquery.factoryitem;

import haxe.htmlparser.HtmlDocument;

class Tools
{
    static public function applyHtmlParams(html:String, params:Hash<Dynamic>) : HtmlDocument
    {
        if (params != null)
		{
            var reConsts = new EReg("[{]([_a-zA-Z][_a-zA-Z0-9]*)[}]", "");
            
            html = reConsts.customReplace(html, function(re) 
            {
                var const = re.matched(1);
                if (params.exists(const))
                {
					return Std.string(params.get(const));
                }
                return re.matched(0);
            });
        }
        
        var xml = null;
        try
        {
            xml = new HtmlDocument(html);
        }
        catch (e:Dynamic)
        {
            trace("XML parse error:\n" + html);
            xml = new HtmlDocument("XML parse error.");
        }
        
        return xml;
    }
}
