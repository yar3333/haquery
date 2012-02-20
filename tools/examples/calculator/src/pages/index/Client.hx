package pages.index;

import components.calculator.Client;
import haquery.client.HaqPage;
import haquery.client.Lib;

class Client extends HaqPage
{
    var template : Template;
	
	public function init()
    {
		var history = q('#history');
		trace(history.size());
		Lib.assert(history.size() == 1);
		template.calc.setHistoryTextArea(history);
    }
}
