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
	
	public function start(db:orm.Db) : Void
	{
		// nothing to do
	}
	
	public function finish(page:models.server.Page) : Void
	{
		// nothing to do
	}
}

#end