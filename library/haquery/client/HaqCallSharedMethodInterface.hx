package haquery.client;

interface HaqCallSharedMethodInterface
{
	function callSharedClientMethod(method:String, params:Array<Dynamic>, callingFromAnother:Bool) : Dynamic;
	function callSharedServerMethod(method:String, params:Array<Dynamic>, callb:Dynamic->Void) : Void;
}
