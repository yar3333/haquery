package haquery.common;

import stdlib.Exception;

#if server
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
	var f : String;
}

class HaqEvent<EventArgs:Dynamic>
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

	public function bind(obj:HaqComponent, method:String)
	{
		handlers.push( { o:obj, f:method } );
		return this;
	}

	public function call(param:EventArgs) : Bool
	{
        var i = handlers.length - 1;
		while (i >= 0)
		{
			var obj = handlers[i].o;
			var func = handlers[i].f;
            
			#if !js
				
				try
				{
					var r = Reflect.callMethod(obj, Reflect.field(obj, func), [ component.parent, param ]);
					if (r == false) return false;
				}
				catch (e:String)
				{
					if (e == "Invalid call")
					{
						throw new Exception("Invalid call: " + Type.getClassName(Type.getClass(obj)) + "." + func + "(t, e).");
					}
					Exception.rethrow(e);
				}
				
			#else
				
				var r = Reflect.callMethod(obj, Reflect.field(obj, func), [ component.parent, param ]);
				if (untyped __js__('r === false')) return false;
				
			#end
			
			i--;
		}
		return true;
	}
}
