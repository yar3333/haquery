package haquery.server;

#if server

class HaqBootstrap
{
	public function new() {}
	
	public function start(request:HaqRequest) : Void
	{
		// nothing to do
	}
	
	public function finish(page:models.server.Page) : Void
	{
		// nothing to do
	}
}

#end