package components.haquery.waiter;

import haquery.client.HaqComponent;

class Client extends HaqComponent
{
	public function show()
	{
        var shadow = q('#shadow');
		var animation = q('#animation');
		
		var selector = q('#shadow').attr('selector');
        var element = parent.q(selector);
        
        shadow.css('top', element.offset().top + "px");
        shadow.css('left', element.offset().left + "px");
        shadow.width(element.outerWidth());
        shadow.height(element.outerHeight());
        shadow.show();
        
        animation.css('top', (element.offset().top + element.outerHeight() / 2 - animation.height() / 2) + "px");
        animation.css('left', (element.offset().left + element.outerWidth() / 2 - animation.width() / 2) + "px");
        animation.show();
	}
	
	public function hide() : Void
	{
		q('#shadow').hide();
		q('#animation').hide();
	}
}