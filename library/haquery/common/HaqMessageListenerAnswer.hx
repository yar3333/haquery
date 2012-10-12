package haquery.common;

enum HaqMessageListenerAnswer
{
	CallSharedMethodAnswer(text:String);
	
	#if !client
	
	MakeRequestAnswer(response:haquery.server.HaqResponse);
	
	#end
}
