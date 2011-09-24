package haquery.components.urlmenu;

import haquery.server.HaqComponent;
import php.Web;
import haquery.server.HaqXml;

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
        
        var bestLink : HaqXmlNodeElement = null;
        var bestDeep = 0;
        var self = this;
        q('#m>a').each(function(index, elem) {
            var href = elem.getAttribute('href').trim('/');
            if (href == 'index') href = '';
            href = self.base + (href != '' ? '/' + href : '');
            
            if (!href.endsWith('.html'))
            {
                href += '/';
            }
            
            elem.setAttribute('href', href);
            
            var uri = Web.getURI().rtrim('/') + '/';
            if (uri == href || uri.startsWith(href))
            {
                if (bestLink == null || href.split('/').length > bestDeep)
                {
                    bestLink = elem;
                    bestDeep = href.split('/').length;
                }
                
            }
        });
        
        if (bestLink != null)
        {
            bestLink.setAttribute('class', 'active');
        }
    }
}