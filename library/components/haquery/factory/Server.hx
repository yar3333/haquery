package components.haquery.factory;

import haquery.HashTools;
import haquery.server.HaqComponent;
import haquery.server.Lib;
import haxe.htmlparser.HtmlNodeElement;

using haquery.StringTools;

class Server extends Base
{
    public var items(default, null) : Array<HaqComponent>;
	
	/**
	 * Limit to creating components on postback. Use to prevent too big server load.
	 * Default is 0 (no limit).
	 */
	public var limit(default, null) : Int;
    
    function new()
    {
		super();
		items = new Array<HaqComponent>();
		limit = 0;
    }
    
    override function createChildComponents():Void 
	{
        if (Lib.isPostback)
        {
			var len = length;
			if (limit > 0 && len > limit)
			{
				trace("HAQUERY components.haquery.factory limit exceed (" + len + " > " + limit + ".");
				len = limit;
			}
			for (i in 0...len)
			{
				manager.createComponent(this, "factoryitem", Std.string(i), null, innerNode, false);
			}
        }
	}
	
	public function create(params:Dynamic) : HaqComponent
	{
        Lib.assert(!Lib.isPostback, "Component creating on the postback is not supported.");
		
		var n = length;
		var r = manager.createComponent(this, "factoryitem", Std.string(n), cast HashTools.hashify(params), getItemInnerNode(), true);
		items.push(r);
		q('#length').val(n + 1);
		return r;
	}
	
    override function render()
    {
        var r = "";
		for (item in items)
        {
            r += item.render().trim() + "\n";
        }
        return r + "\n" + super.render();
    }
    
	function getItemInnerNode() : HtmlNodeElement
	{
		return innerNode;
	}
}
