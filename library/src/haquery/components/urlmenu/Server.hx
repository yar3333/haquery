package haquery.components.urlmenu;

import haquery.server.HaqComponent;
import php.Web;
using haquery.StringTools;
typedef Container = haquery.components.container.Server;

class Server extends Container
{
    public var base : String;
    public var cssClass : String;
    
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
        if (cssClass != null)
        {
            q('#m').addClass(cssClass);
        }
        
        var self = this;
        q('#m>a').each(function(index, elem) {
            var href = elem.getAttribute('href').trim('/');
            if (href == 'index') href = '';
            href = self.base + '/' + (href != '' ? href + '/' : '');
            
            elem.setAttribute('href', href);
            
            var uri = Web.getURI().rtrim('/') + '/';
            if (uri == href || uri.startsWith(href))
            {
                elem.setAttribute('class', 'active');
            }
        });
    }
}