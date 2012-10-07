package haquery.common;

enum HaqMessage
{
	#if !client
	MakeRequest(request:haquery.server.HaqRequest);
	#else
	MakeRequest(request:Dynamic);
	#end
	
	ConnectToPage(pageUuid:String);
	
	CallSharedMethod(componentFullID:String, method:String, params:Array<Dynamic>);
	
	Status;
	
	Stop;
}
