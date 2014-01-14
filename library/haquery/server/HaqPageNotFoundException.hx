package haquery.server;

class HaqPageNotFoundException extends stdlib.Exception
{
	public function new(url:String)
	{
		super(url);
	}
}
