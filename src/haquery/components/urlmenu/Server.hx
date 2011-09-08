package haquery.components.urlmenu;

import haquery.server.HaqComponent;
import php.Web;
typedef Container = haquery.components.container.Server;

class Server extends Container
{
    public var base : String;
    
    override function getHeader() : String 
    {
        return '<div id="m" class="urlmenu">\n';
    }
    
    override function getFooter() : String 
    {
        return '\n</div>';
    }
    
    function preRender()
    {
        var self = this;
        q('#m>a').each(function(index, elem) {
            var href = elem.getAttribute('href').trim('/');
            if (href == 'index') href = '';
            elem.setAttribute('href', self.base + '/' + (href != '' ? href + '/' : ''));
            
            var uri = Web.getURI().trim('/');
            trace(uri);
            if (uri == href || uri.startsWith(href + '/'))
            {
                elem.setAttribute('class', 'active');
            }
        });
    }
}