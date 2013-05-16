package haquery.server;

#if server

class HaqBootstrap
{
	public function new() {}
	
	public function start(request:HaqRequest) : Void
	{
		// nothing to do
	}
	
	public function finish(page:haquery.server.BasePage) : Void
	{
		// nothing to do
	}
}

#end