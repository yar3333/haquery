package components.haquery.factory;

import haquery.Exception;
import haquery.server.HaqComponent;
import haquery.server.Lib;
import haquery.Std;
import haxe.htmlparser.HtmlNodeElement;
using haquery.StringTools;

class Server extends Base
{
    override function createChildComponents():Void 
	{
        if (!page.isPostback)
		{
			components = new DirectItems();
		}
		else
        {
			components = new LazyItems(length, function(id:String)
			{
				return manager.createComponent(this, "factoryitem", id, null, innerNode, false);
			});
        }
	}
	
	public function create(params:Dynamic) : HaqComponent
	{
        Lib.assert(!page.isPostback, "Component creating on the postback is not supported.");
		
		var n = length;
		var r = manager.createComponent(this, "factoryitem", Std.string(n), Std.hash(params), getItemInnerNode(), true);
		q('#length').val(n + 1);
		return r;
	}
	
    override function render()
    {
        var r = "";
		for (item in components)
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
