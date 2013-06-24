package haquery.client;

#if client

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
		ajax = new HaqServerCallerAjax(this);
    }
    
    public function redirect(url:String) : Void
    {
        if (js.Lib.window.location.href == url)
		{
			js.Lib.window.location.reload(true);
		}
        else
		{
			js.Lib.window.location.href = url;
		}
    }

	public function reload() : Void
	{
        js.Lib.window.location.reload(true);
	}
}

#end