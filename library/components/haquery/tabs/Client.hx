package components.haquery.tabs;

import haquery.common.HaqEvent;

class Client extends BaseClient
{
	var event_change : HaqEvent<{ active:Int }>;
    
	public var active(getActive, setActive) : Int;

    function init()
    {
        var self = this;
        
        var tabs = template().container.find('>*:eq(0)>*').get();
		for (i in 0...tabs.length)
		{
			q(tabs[i]).click(function(e)
            {
                self.active = i;
				event_change.call( { active:i } );
            });
		}
        
        active = 0;
    }
    
    function getActive() : Int
    {
        var panels = template().container.find('>*:eq(1)>*').get();
		for (i in 0...panels.length)
		{
			if (q(panels[i]).hasClass('active')) return i;
		}
        return -1;
    }

    function setActive(n:Int) : Int
    {
        var container = template().container;
		
		container.find('>*:eq(0)>*').removeClass('active');
        container.find('>*:eq(0)>*:eq(' + n + ')').addClass('active');
        container.find('>*:eq(1)>*').removeClass('active').hide();
        container.find('>*:eq(1)>*:eq(' + n + ')').addClass('active').show();
        
        return n;
    }
}
