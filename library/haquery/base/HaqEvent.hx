package haquery.base;

#if php
	import haquery.server.HaqComponent;
    import haquery.server.Lib;
    import haquery.server.HaqQuery;
#else
	import haquery.client.HaqComponent;
    import haquery.client.Lib;
    import haquery.client.HaqQuery;
#end

private typedef Handler = {
	var o : HaqComponent;
	var f : HaqComponent->Dynamic->Bool;
}

class HaqEvent
{
	var handlers : Array<Handler>;
	
	public var component(default,null) : HaqComponent;
	public var name(default,null) : String;
	
	public function new(component:HaqComponent, name:String):Void
	{
		this.handlers = new Array<Handler>();
		this.component = component;
		this.name = name;
	}

	public function bind(obj:HaqComponent, func:HaqComponent->Dynamic->Bool)
	{
		handlers.push( { o: obj, f: func } );
		return this;
	}

	public  function call(params:Array<Dynamic>=null) : Bool
	{
		//trace("Event call for " + component.fullID + " - " + name + " #" + handlers.length);
        
        if (params == null) params = [];
		
        var i = handlers.length - 1;
		while (i>=0)
		{
			var obj = handlers[i].o;
			var func = handlers[i].f;
            var r = Reflect.callMethod(obj, func, cast([component.parent], Array<Dynamic>).concat(params));
			#if php
				if (r == false) return false;
			#else
				if (untyped __js__('r === false')) return false;
			#end
			i--;
		}
		return true;
	}
}
