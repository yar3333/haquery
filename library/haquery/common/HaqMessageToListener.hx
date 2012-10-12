package haquery.common;

enum HaqMessageToListener
{
	ConnectToPage(pageKey:String, pageSecret:String);
	CallSharedMethod(componentFullID:String, method:String, params:Array<Dynamic>);
	
	#if !client
	
	MakeRequest(request:haquery.server.HaqRequest);
	Status;
	Stop;
	
	#end
}
