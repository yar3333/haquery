package haquery.server;

interface HaqCallSharedMethodInterface
{
	function callSharedClientMethodDelayed(method:String, params:Array<Dynamic>) : Void;
	function callSharedServerMethod(method:String, params:Array<Dynamic>, callingFromAnother:Bool) : Dynamic;
}
