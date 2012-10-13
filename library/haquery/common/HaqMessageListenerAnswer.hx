package haquery.common;

enum HaqMessageListenerAnswer
{
	CallSharedMethodAnswer(text:String);
	CallAnotherClientMethod(componentFullID:String, method:String, params:Array<Dynamic>);
	
	#if !client
	
	MakeRequestAnswer(response:haquery.server.HaqResponse);
	
	#end
}
