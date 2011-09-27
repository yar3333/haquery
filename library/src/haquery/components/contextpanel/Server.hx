package haquery.components.contextpanel;

class Server extends haquery.components.container.Server
{
    public var dataID(dataID_getter, null) : String;
    function dataID_getter() : String
    {
        return q('#dataID').val();
    }
    
    override function getHeader() : String 
    {
        return '<div id="p" class="contextpanel" style="display:none">\n<input type="hidden" id="dataID" />';
    }
    
    override function getFooter() : String 
    {
        return '\n</div>';
    }
}
