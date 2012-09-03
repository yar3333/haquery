package pages.index;

import haquery.client.Lib;
import haquery.client.HaqPage;

class Client extends HaqPage
{
    public function init()
    {
		var history = q('#history');
		trace(history.size());
		Lib.assert(history.size() == 1);
		template().calc.setHistoryTextArea(history);
    }
}
