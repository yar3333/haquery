package haquery.components.checkbox;

import haquery.server.HaqComponent;
import haquery.server.HaqTools;
import haquery.server.Lib;

class Server extends HaqComponent
{
    public var checked : Bool;
    
    function init()
    {
        if (Lib.isPostback)
        {
            checked = HaqTools.bool(q('#checked').val());
        }
    }
    
    function preRender()
    {
        q('#checked').val(checked ? '1' : '0');
        if (checked)
        {
            q('#check').attr("checked", "checked");
        }
        else
        {
            q('#check').removeAttr("checked");
        }
    }
}