package haquery.components.radioboxes;

import js.Dom;
import haquery.client.HaqEvent;
import haquery.client.HaqQuery;

class Client extends haquery.components.container.Client
{
    public var value(value_getter, value_setter) : String;
    
    var event_change : HaqEvent;
    
    function init()
    {
        for (elem in getInputElements())
        {
            elem.change(function(e) return event_change.call([e]));
        }
    }
    
    function getInputElements() : List<HaqQuery>
    {
        var inputs = new List<HaqQuery>();
        var index = 0;
        var elem = null;
        while ((elem = q('#' + index)).size() > 0)
        {
            inputs.push(elem);
            index++;
        }
        return inputs;
    }
    
    function value_getter() : String
    {
        for (elem in getInputElements())
        {
            if (elem.is(":checked"))
            {
                return elem.attr("value");
            }
        }
        return null;
    }
    
    function value_setter(v:String) : String
    {
        for (elem in getInputElements())
        {
            if (elem.attr("value") == v)
            {
                elem.attr("checked", "checked");
            }
            else
            {
                elem.removeAttr("checked");
            }
        }
        return v;
    }
    
}