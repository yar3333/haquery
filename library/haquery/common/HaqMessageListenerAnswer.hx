package haquery.common;

enum HaqMessageListenerAnswer
{
	CallSharedServerMethodAnswer(text:String);
	CallAnotherClientMethod(componentFullID:String, method:String, params:Array<Dynamic>);
	
	ProcessUncalledServerMethodAnswer(text:String);
	
	#if !client
	
	MakeRequestAnswer(response:haquery.server.HaqResponse);
	
	#end
}
