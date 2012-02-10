package haquery.components.tabs;

import haquery.client.HaqQuery;
import haquery.client.HaqEvent;
import haquery.client.HaqComponent;

class Client extends haquery.components.container.Client
{
    public var active(active_getter, active_setter) : Int;

    function init()
    {
        var self = this;
        q('#tabs>*:eq(0)>*').each(function(index, elem)
        {
            new HaqQuery(elem).click(function(e)
            {
                self.active = index;
            });
        });
        
        active = 0;
    }
    
    function active_getter() : Int
    {
        var r = -1;
        q('#tabs>*:eq(1)>*').each(function(index, elem)
        {
            if (new HaqQuery(elem).hasClass('active'))
            {
                r = index;
            }
        });
        return r;
    }

    function active_setter(n:Int) : Int
    {
        q('#tabs>*:eq(0)>*').each(function(index, elem)
        {
            new HaqQuery(elem).removeClass('active');
        });
        q('#tabs>*:eq(0)>*:eq(' + n + ')').addClass('active');
        
        q('#tabs>*:eq(1)>*').each(function(index, elem)
        {
            new HaqQuery(elem).removeClass('active').hide();
        });
        q('#tabs>*:eq(1)>*:eq(' + n + ')').addClass('active').show();
        
        return n;
    }
    
/*    public function select()
    {
        var self = this;
        q('#tabs>div').each(function(index,elem) {
            var elemID = elem.id.substr(self.prefixID.length);
            if (elemID != tabID)
            {
                new HaqQuery(elem).removeClass('active');
                self.parent.q('#' + new HaqQuery(elem).attr('panelID')).removeClass('active');
                self.event_hided.call([elemID]);
            }
        });
        q('#'+tabID).addClass('active');
        parent.q('#' + q('#' + tabID).attr('panelID')).addClass('active');
        event_selected.call([tabID]);
    }*/
}
