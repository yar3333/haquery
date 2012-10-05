package haquery.common;

enum HaqDaemonMessage
{
	#if !client
	Server(request:haquery.server.HaqRequest);
	#else
	Server(request:Dynamic);
	#end
	
	Client(pageUuid:String, componentFullID:String, method:String, params:Array<Dynamic>);
}
