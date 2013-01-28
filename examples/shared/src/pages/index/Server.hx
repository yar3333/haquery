package pages.index;

class Server extends BaseServer
{
    function init()
	{
		trace("server init");
	}
	
	function simpleButton_click(t, e)
	{
		q('#status').html("simpleButton pressed on server");
	}
	
    function componentButton_click(t, e)
	{
		q('#status').html("componentButton pressed on server");
	}
	
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
	
	@shared function serverMethodD(anotherPageKey:String) : String
	{
		trace("serverMethodD anotherPageKey = " + anotherPageKey);
		client(anotherPageKey).clientMethodD(10, "MyAnother");
		return "from serverMethodD";
	}
	
	@another function serverMethodE(fromPageKey:String) : String
	{
		trace("serverMethodE [" + pageKey + "] from [" + fromPageKey + "]");
		return "hello from " + pageKey;
	}
}