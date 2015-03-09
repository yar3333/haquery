package haquery.client;

import js.Browser;
import haquery.client.HaqComponent;
import haquery.client.HaqCookie;
import haquery.common.HaqStorage;

class HaqPage extends HaqComponent
{
    public var cookie(default, null) : HaqCookie;

    public var storage(default, null) : HaqStorage;
    
	public var ajax(default, null) : HaqServerCallerAjax;
	
	public function new()
    {
		super();
		cookie = new HaqCookie();
		storage = HaqInternals.storage;
		ajax = new HaqServerCallerAjax(this, Browser.window.location.href);
    }
    
    public function redirect(url:String) : Void
    {
        if (Browser.window.location.href == url)
		{
			reload();
		}
        else
		{
			Browser.window.location.href = url;
		}
    }

	public function reload() : Void
	{
        untyped __js__("window.location.reload(true)");
	}
}
