package haquery.components.urlmenu;

import haquery.server.HaqComponent;
import php.Web;
import haquery.server.HaqXml;
import haquery.server.Lib;

using haquery.StringTools;

class Server extends haquery.components.container.Server
{
    public var base : String;
    public var cssClass : String;
    
    function preRender()
    {
        if (cssClass != null)
        {
            q('#m').addClass(cssClass);
        }
        
        var bestLink : HaqXmlNodeElement = null;
        var bestDeep = 0;
        var self = this;
        
        for (node in Lib.toHaxeArray(parentNode.children))
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
                    bestLink = elem;
                    bestDeep = href.split('/').length;
                }
                
            }
        }
        
        if (bestLink != null)
        {
            bestLink.setAttribute('class', 'active');
        }
    }
}