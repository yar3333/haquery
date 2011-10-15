package haquery.components.shadow;

import haquery.client.HaqComponent;
import haquery.client.HaqQuery;
import js.Lib;

class Client extends HaqComponent
{
	public function show()
	{
        var shadow = q('#shadow');
        var element = new HaqQuery(js.Lib.document.body);
        shadow.width(element.width());
        shadow.height(element.height());
        shadow.show();
	}
	
	public function hide() : Void
	{
		q('#shadow').hide();
	}
}