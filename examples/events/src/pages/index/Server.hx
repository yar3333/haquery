package pages.index;

import haquery.server.HaqPage;

class Server extends HaqPage
{
	public function init()
    {
    }
    
    public function mybt1_click()
	{
		q('#status').html("mybt1 server pressed!");
	}
	
    public function mybt2_click()
	{
        //throw "MYERR";
		q('#status').html("mybt2 server pressed!");
	}
}