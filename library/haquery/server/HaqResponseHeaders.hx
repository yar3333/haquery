package haquery.server;

class HaqResponseHeaders
{
    var isPostback : Bool;
	
	var headers : List<{ value:String, header:String }>;
	
	public function new() : Void
	{
		headers = new List<{ value:String, header:String }>();
	}
	
	public function set(name:String, value:String) : Void
	{
		headers.push({ header:name, value:value });
	}
	
	public function send()
	{
		for (h in headers)
		{
			Web.setHeader(h.header, h.value);
		}
	}
}
