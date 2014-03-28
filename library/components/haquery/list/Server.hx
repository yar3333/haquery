package components.haquery.list;

import haquery.common.HaqStorage;
import haquery.server.Lib;
import haxe.htmlparser.HtmlNodeElement;
import stdlib.Std;
import stdlib.Debug;
import haquery.server.HaqComponent;
using stdlib.StringTools;

class Server extends BaseServer
{
	public var length(get_length, null) : Int;
    
    function get_length() : Int
    {
		return page.storage.existsInstanceVar(fullID, "length")
			? page.storage.getInstanceVar(fullID, "length")
			: 0;
    }
	
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
				return Lib.manager.createComponent(this, "components.haquery.listitem", id, null, innerNode, false);
			});
        }
	}
	
	function create(params:Dynamic) : HaqComponent
	{
        Debug.assert(!page.isPostback, "Component creating on the postback is not supported.");
		
		var n = length;
		var r = Lib.manager.createComponent(this, "components.haquery.listitem", Std.string(n), params, getItemInnerNode(), true);
		page.storage.setInstanceVar(fullID, "length", n + 1, HaqStorage.DESTINATION_BOTH);
		return r;
	}
	
	public function bind<Data>(objects:Iterable<Data>, ?itemDataBound:HaqComponent->Data->Void)
    {
        Debug.assert(!page.isPostback, "List binding on postback is not allowed.");
		
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
		var buf = new StringBuf();
		for (item in components)
        {
            buf.add(item.render());
			buf.add("\n");
        }
		buf.add("\n");
		buf.add(super.render());
		return buf.toString();
    }
    
	function getItemInnerNode() : HtmlNodeElement
	{
		return innerNode;
	}
}
