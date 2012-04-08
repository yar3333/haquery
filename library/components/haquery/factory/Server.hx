package components.haquery.factory;

import haquery.HashTools;
import haquery.server.HaqComponent;
import haquery.server.Lib;
import haxe.htmlparser.HtmlNodeElement;

using haquery.StringTools;

class Server extends Base
{
    override function createChildComponents():Void 
	{
        if (Lib.isPostback)
        {
			for (i in 0...length)
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
		q('#length').val(Std.string(n + 1));
		return r;
	}
	
    override function render()
    {
        var r = "";
		for (component in components)
        {
            r += component.render().trim() + "\n";
        }
        return r + "\n" + super.render();
    }
    
	function getItemInnerNode() : HtmlNodeElement
	{
		return innerNode;
	}
}
