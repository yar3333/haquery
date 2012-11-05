package components.haquery.radioboxes;

import haquery.common.HaqEvent;
import haquery.client.HaqQuery;
import js.JQuery;

class Client extends BaseClient
{
    public var value(getValue, setValue) : String;
    
    var event_change : HaqEvent<JqEvent>;
    
    function init()
    {
        for (elem in getInputElements())
        {
            elem.change(function(e) { event_change.call(e); } );
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
    
    function getValue() : String
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
    
    function setValue(v:String) : String
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