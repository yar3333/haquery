package haquery.components.checkbox;

import haquery.server.HaqComponent;
import haquery.server.HaqTools;
import haquery.server.Lib;

class Server extends HaqComponent
{
    public var value : Bool;
    
    public function new()
    {
        super();
        value = false;
    }
    
    function init()
    {
        if (Lib.isPostback)
        {
            value = HaqTools.bool(q('#value').val());
        }
    }
    
    function preRender()
    {
        q('#value').val(value ? '1' : '0');
        if (value)
        {
            q('#check').attr("checked", "checked");
        }
        else
        {
            q('#check').removeAttr("checked");
        }
    }
}