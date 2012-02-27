package components.haquery.urlmenu;

import haquery.server.HaqComponent;
import haquery.server.HaqXml;
import haquery.server.HaqQuery;
import haquery.server.Lib;
import haquery.server.Web;

using haquery.StringTools;

class Server extends HaqComponent
{
    public var base : String;
    public var cssClass : String;
    
    function preRender()
    {
        if (cssClass != null)
        {
            q('#m').addClass(cssClass);
        }
        
        var bestLink : HaqQuery = null;
        var bestDeep = 0;
        var self = this;
        
        for (node in parentNode.children)
        {
            var elem : HaqXmlNodeElement = cast node;
            
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
                    bestLink = q(elem);
                    bestDeep = href.split('/').length;
                }
                
            }
        }
        
        if (bestLink != null)
        {
            bestLink.addClass('active');
        }
    }
}