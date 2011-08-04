package pages.index;

import js.Lib;
import components.calculator.Client;
import haquery.client.HaqPage;

class Client extends HaqPage
{
    public function init()
    {
		var calculator : components.calculator.Client = cast(components.get('calc'), components.calculator.Client);
		calculator.setHistoryTextArea(q('#history'));
    }
}
