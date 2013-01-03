package haquery.common;

enum HaqMessageToListener
{
	ConnectToPage(pageKey:String, pageSecret:String);
	
	CallSharedServerMethod(componentFullID:String, method:String, params:Array<Dynamic>);
	CallAnotherClientMethod(pageKey:String, componentFullID:String, method:String, params:Array<Dynamic>);
	CallAnotherServerMethod(pageKey:String, componentFullID:String, method:String, params:Array<Dynamic>);
	
	#if !client
	
	MakeRequest(request:haquery.server.HaqRequest);
	Status;
	Stop;
	
	#end
}
