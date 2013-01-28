package pages.index;

class Server extends BaseServer
{
	@shared function serverMethodA(a:Int, b:String) : String
	{
		trace("serverMethodA");
		client().clientMethodA(10, "a");
		return "serverMethodA answer:" + a + "-" + b;
	}
	
	@shared function serverMethodB(anotherPageKey:String) : String
	{
		trace("serverMethodB");
		return server(anotherPageKey).serverMethodC(pageKey);
	}
	
	@another function serverMethodC(fromPageKey:String) : String
	{
		trace("serverMethodC");
		return pageKey;
	}
	
	@another function serverMethodE(fromPageKey:String) : String
	{
		trace("serverMethodE [" + pageKey + "] from [" + fromPageKey + "]");
		return "hello from " + pageKey;
	}
}