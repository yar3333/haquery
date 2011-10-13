package components.checkbox;

import haquery.server.HaqComponent;
import haquery.server.HaqTools;
import haquery.server.HaQuery;

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
        if (HaQuery.isPostback)
        {
            value = HaqTools.bool(q('#value').val());
        }
    }
    
    function preRender()
    {
        q('#value').val(value ? '1' : '0');
    }
}