package haquery.server;

#if server

class HaqBootstrap
{
	var config(default, null) : HaqConfig;
	
	public function new(config:HaqConfig)
	{
		this.config = config;
	}
	
	public function init(request:HaqRequest) : Void
	{
		// nothing to do
	}
	
	public function start() : Void
	{
		// nothing to do
	}
	
	public function finish(page:HaqPage) : Void
	{
		// nothing to do
	}
}

#end