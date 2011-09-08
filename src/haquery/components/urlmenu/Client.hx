package haquery.components.urlmenu;

import haquery.client.HaqInternals;
import haquery.client.HaqQuery;
import haquery.client.HaQuery;
import js.Dom;
import haquery.client.HaqComponent;
typedef Container = haquery.components.container.Client;

class Client extends Container
{
    public function init()
    {
        /*var elems = q('#m>li');
        elems.each(function(index, elem:HtmlDom) {
            //js.Lib.alert(elem.id);
            (new HaqQuery(elem)).click(function() {
                var id = elem.id.substr(elem.id.lastIndexOf(HaqInternals.DELIMITER) + 1);
                js.Lib.alert(id);  
                HaQuery.redirect(id); 
            } );
        });*/
    }
    
}