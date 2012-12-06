package haquery.client;

#if client

import haquery.client.HaqComponent;
import haquery.client.HaqCookie;

class HaqPage extends HaqComponent
{
    public var cookie(default, null) : HaqCookie;
    
	/**
	 * Page's unique id for server pages list.
	 */
	public var pageKey(default, null) : String;
	
	/**
	 * Page's secret keyword for security when connectiong to server.
	 */
	public var pageSecret(default, null) : String;
    
	public function new()
    {
		super();
		cookie = new HaqCookie();
		pageKey = HaqInternals.pageKey;
		pageSecret = HaqInternals.pageSecret;
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
	
	/**
	 * Overload to specify code on client to server websocket connection.
	 * You can return false to force to ignore calling queue.
	 */
	public function onConnect() return true
	
	/**
	 * Overload to specify code on client to server websocket closing.
	 */
	public function onDisconnect() {}
}

#end