package components.haquery.shadow;

import haquery.client.HaqComponent;
import js.Lib;
import js.JQuery;

class Client extends HaqComponent
{
	public function show()
	{
        var shadow = q('#shadow');
        var element = new JQuery(js.Lib.document.body);
        shadow.width(element.width());
        shadow.height(element.height());
        shadow.show();
	}
	
	public function hide() : Void
	{
		q('#shadow').hide();
	}
}