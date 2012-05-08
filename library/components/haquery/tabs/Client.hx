package components.haquery.tabs;

import haquery.client.HaqQuery;
import haquery.client.HaqEvent;
import haquery.client.HaqComponent;
import js.JQuery;

class Client extends HaqComponent
{
    public var active(active_getter, active_setter) : Int;

    function init()
    {
        var self = this;
        
        var tabs = q('#tabs>*:eq(0)>*').get();
		for (i in 0...tabs.length)
		{
			q(tabs[i]).click(function(e)
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
			if (q(panels[i]).hasClass('active')) return i;
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
}
