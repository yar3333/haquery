package haquery.components.radioboxes;

import haquery.server.HaqDefines;
import models.Users;
import haquery.server.HaqXml;
import haquery.server.Lib;
import php.Web;

using haquery.StringTools;

class Server extends haquery.components.container.Server
{
    public var value(value_getter, value_setter) : String;
    
    function getInputElements() : List<HaqXmlNodeElement>
    {
        var inputs : Array<HaqXmlNodeElement> = cast Lib.toHaxeArray(parentNode.find("input"));
        return Lambda.filter(inputs, function(input) return input.getAttribute('type').toLowerCase()=='radio');
    }
    
    function value_getter() : String
    {
        if (!Lib.isPostback)
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
            return Web.getParams().get(prefixID + "v");
        }
    }
    
    function value_setter(v:String) : String
    {
        if (!Lib.isPostback)
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
            throw "Setting radioboxes value on postback is not supported.";
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
}