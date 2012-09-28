package components.haquery.radioboxes;

import haquery.Exception;
import haquery.common.HaqDefines;
import haquery.server.Lib;
import haquery.server.HaqComponent;
import haxe.htmlparser.HtmlNodeElement;

using haquery.StringTools;

class Server extends HaqComponent
{
    public var value(getValue, setValue) : String;
    
    function getInputElements() : List<HtmlNodeElement>
    {
        var inputs = innerNode.find("input");
        return Lambda.filter(inputs, function(input) return input.getAttribute('type').toLowerCase()=='radio');
    }
    
    function getValue() : String
    {
        if (!page.isPostback)
        {
            for (elem in getInputElements())
            {
                if (elem.hasAttribute("checked"))
                {
                    return elem.getAttribute("value");
                }
            }
            return null;
        }
        else
        {
            return page.params.get(prefixID + "v");
        }
    }
    
    function setValue(v:String) : String
    {
        if (!page.isPostback)
        {
            for (elem in getInputElements())
            {
                if (elem.getAttribute("value")==v)
                {
                    elem.setAttribute("checked", "checked");
                }
                else
                {
                    elem.removeAttribute("checked");
                }
            }
        }
        else
        {
            throw new Exception("Setting radioboxes value on postback is not supported.");
        }
        return v;
    }
    
    function preRender()
    {
        var index = 0;
        for (elem in getInputElements())
        {
            elem.setAttribute("id", id + HaqDefines.DELIMITER + index);
            elem.setAttribute("name", prefixID + "v");
            index++;
        }
    }
	
	override function loadFieldValues(params:Hash<String>) 
	{
		super.loadFieldValues(params);
		
		if (!page.isPostback)
		{
			if (params.exists("value"))
			{
				value = params.get("value");
			}
		}
	}
}