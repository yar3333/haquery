package haquery.components.urlmenu;

import haquery.client.HaqInternals;
import haquery.client.HaqQuery;
import haquery.client.Lib;
import js.Dom;
import haquery.client.HaqComponent;

class Client extends haquery.components.container.Client
{
    function init()
    {
        /*var elems = q('#m>li');
        elems.each(function(index, elem:HtmlDom) {
            //js.Lib.alert(elem.id);
            (new HaqQuery(elem)).click(function() {
                var id = elem.id.substr(elem.id.lastIndexOf(HaqDefines.DELIMITER) + 1);
                js.Lib.alert(id);  
                Lib.redirect(id); 
            } );
        });*/
    }
    
}