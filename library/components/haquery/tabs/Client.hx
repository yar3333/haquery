package components.haquery.tabs;

import haquery.client.HaqQuery;
import haquery.client.HaqEvent;
import haquery.client.HaqComponent;
import js.JQuery;

class Client extends components.haquery.container.Client
{
    public var active(active_getter, active_setter) : Int;

    function init()
    {
        var self = this;
        
        var tabs = q('#tabs>*:eq(0)>*').get();
		for (i in 0...tabs.length)
		{
			new JQuery(tabs[i]).click(function(e)
            {
                self.active = i;
            });
		}
        
        active = 0;
    }
    
    function active_getter() : Int
    {
        var panels = q('#tabs>*:eq(1)>*').get();
		for (i in 0...panels.length)
		{
			if (new JQuery(panels[i]).hasClass('active')) return i;
		}
        return -1;
    }

    function active_setter(n:Int) : Int
    {
        q('#tabs>*:eq(0)>*').removeClass('active');
        q('#tabs>*:eq(0)>*:eq(' + n + ')').addClass('active');
        q('#tabs>*:eq(1)>*').removeClass('active').hide();
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
