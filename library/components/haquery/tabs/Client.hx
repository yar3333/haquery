package components.haquery.tabs;

import haquery.common.HaqEvent;

class Client extends BaseClient
{
	var event_change : HaqEvent<{ activeIndex:Int }>;
    
	public var activeIndex(get_activeIndex, set_activeIndex) : Int;

    function init()
    {
        var tabs = template().container.find('>*:eq(0)>*').get();
		for (i in 0...tabs.length)
		{
			q(tabs[i]).click(function(e)
            {
                activeIndex = i;
				event_change.call( { active:i } );
            });
		}
        
        active = 0;
    }
    
    function get_activeIndex() : Int
    {
        var tabs = template().container.find('>*:eq(0)>*').get();
		for (i in 0...tabs.length)
		{
			if (q(tabs[i]).hasClass('active')) return i;
		}
        return -1;
    }

    function set_activeIndex(n:Int) : Int
    {
        var container = template().container;
		
		container.find('>*:eq(0)>*').removeClass('active');
        container.find('>*:eq(0)>*:eq(' + n + ')').addClass('active');
        container.find('>*:eq(1)>*').removeClass('active').hide();
        container.find('>*:eq(1)>*:eq(' + n + ')').addClass('active').show();
        
        return n;
    }
}
