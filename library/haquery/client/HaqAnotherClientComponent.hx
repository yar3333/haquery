package haquery.client;

class HaqAnotherClientComponent implements HaqCallSharedMethodInterface
{
	var pageKey : String;
	var componentFullID : String;

	public function new(pageKey:String, component:HaqComponent)
	{
		this.pageKey = pageKey;
		this.componentFullID = componentFullID;
	}
	
	public function callSharedMethod(method:String, ?params:Array<Dynamic>) : Void
	{
		Lib.websocket.callSharedMethod("", "callAnotherClientSharedMethod", [ pageKey, componentFullID, method, params ]
	}
}