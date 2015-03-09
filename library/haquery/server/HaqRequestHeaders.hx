package haquery.server;

class HaqRequestHeaders
{
    public function new() {}
	
	public function get(name:String) : String
    {
		return Web.getClientHeader(name);
    }
}
