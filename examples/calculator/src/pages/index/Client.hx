package pages.index;

import haquery.client.Lib;
import haquery.client.HaqPage;

class Client extends HaqPage
{
    var template : TemplateClient;
	
	public function init()
    {
		var history = q('#history');
		trace(history.size());
		Lib.assert(history.size() == 1);
		template.calc.setHistoryTextArea(history);
    }
}
