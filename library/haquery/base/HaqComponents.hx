package haquery.base;

typedef HaqComponents<Component> =
{
	function get(id:String) : Component;
	function set(id:String, com:Component) : Void;
	function exists(id:String) : Bool;
	function iterator() : StdTypes.Iterator<Component>;
	function remove(id:String) : Bool;
}