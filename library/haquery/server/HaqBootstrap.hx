package haquery.server;

#if server

class HaqBootstrap
{
	var config(default, null) : HaqConfig;
	
	public function new(config:HaqConfig)
	{
		this.config = config;
	}
	
	public function init(request:haquery.server.HaqRequest) : Void
	{
		// nothing to do
	}
	
	public function start(db:haquery.server.db.HaqDb) : Void
	{
		// nothing to do
	}
	
	public function finish(page:haquery.server.HaqPage) : Void
	{
		// nothing to do
	}
}

#end