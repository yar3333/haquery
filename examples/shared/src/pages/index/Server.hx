package pages.index;

class Server extends BaseServer
{
	@shared function sharedServerMethod(a:Int, b:Int) : Int
	{
		client().sharedClientMethod(a + 1, b + 1);
		return a + b;
	}
}