package haquery.common;

enum HaqMessageListenerAnswer
{
	CallSharedServerMethodAnswer(ajaxResponse:String, result:Dynamic);
	CallAnotherClientMethod(componentFullID:String, method:String, params:Array<Dynamic>);
	CallAnotherServerMethodAnswer(result:Dynamic);
	ProcessUncalledServerMethodAnswer(ajaxResponse:String);
	
	#if !client
	
	MakeRequestAnswer(response:haquery.server.HaqResponse);
	
	#end
}
