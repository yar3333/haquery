package haquery.components.contextpanel;

class Server extends haquery.components.container.Server
{
    override function getHeader() : String 
    {
        return '<div id="p" class="contextpanel" style="display:none">\n';
    }
    
    override function getFooter() : String 
    {
        return '\n</div>';
    }
}
