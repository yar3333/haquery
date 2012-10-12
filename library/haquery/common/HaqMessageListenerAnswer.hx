package haquery.common;

enum HaqMessageListenerAnswer
{
	CallSharedMethodAnswer(text:String);
	CallClientMethodFromAnother(componentFullID:String, method:String, params:Array<Dynamic>);
	
	#if !client
	
	MakeRequestAnswer(response:haquery.server.HaqResponse);
	
	#end
}
