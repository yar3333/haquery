package haquery.common;

import haquery.Exception;

enum CallbackResult
{
	Success(ret:Dynamic);
	Fail(error:Exception);
}

enum HaqMessageListenerAnswer
{
	CallAnotherClientMethod(componentFullID:String, method:String, params:Array<Dynamic>);
	
	CallAnotherClientMethodAnswer(result:CallbackResult);
	CallSharedServerMethodAnswer(ajaxResponse:String, result:CallbackResult);
	CallAnotherServerMethodAnswer(result:CallbackResult);
	ProcessUncalledServerMethodAnswer(ajaxResponse:String);
	
	#if !client
	
	MakeRequestAnswer(response:haquery.server.HaqResponse);
	
	#end
}
