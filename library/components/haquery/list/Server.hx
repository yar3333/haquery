package components.haquery.list;

import haxe.htmlparser.HtmlNodeElement;
import stdlib.Std;
import stdlib.Exception;
import haquery.server.HaqComponent;
using stdlib.StringTools;

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
				return manager.createComponent(this, "components.haquery.listitem", id, null, innerNode, false);
			});
        }
	}
	
	public function create(params:Dynamic) : HaqComponent
	{
        Std.assert(!page.isPostback, "Component creating on the postback is not supported.");
		
		var n = length;
		var r = manager.createComponent(this, "components.haquery.listitem", Std.string(n), Std.hash(params), getItemInnerNode(), true);
		q('#length').val(n + 1);
		return r;
	}
	
	public function bind<Data>(objects:Iterable<Data>, ?itemDataBound:HaqComponent->Data->Void)
    {
        Std.assert(!page.isPostback, "List binding on postback is not allowed.");
		
        for (obj in objects)
        {
            var item = create(obj);
			if (itemDataBound != null)
			{
				itemDataBound(item, obj);
			}
        }
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
