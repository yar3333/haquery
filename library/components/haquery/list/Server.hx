package components.haquery.list;

import haquery.server.Lib;
import haxe.htmlparser.HtmlNodeElement;
import stdlib.Std;
import stdlib.Debug;
import haquery.server.HaqComponent;
using stdlib.StringTools;

class Server extends BaseServer
{
	public var length(get_length, null) : Int;
	
	var binded = false;
    
    function get_length() : Int
    {
		return Lambda.count(components);
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
		
		return Lib.manager.createComponent(this, "components.haquery.listitem", Std.string(length), params, getItemInnerNode(), true);
	}
	
	public function bind<Data>(objects:Iterable<Data>, ?itemDataBound:HaqComponent->Data->Void)
    {
        Debug.assert(!page.isPostback, "List binding on postback is not allowed.");
        Debug.assert(!binded, "Rebinding is not allowed.");
		
		binded = true;
		
        for (obj in objects)
        {
            var item = create(obj);
			if (itemDataBound != null)
			{
				itemDataBound(item, obj);
			}
        }
    }
	
    override function renderDirect()
    {
		var buf = new StringBuf();
		for (item in components)
        {
            buf.add(item.renderCached());
			buf.add("\n");
        }
		buf.add("\n");
		buf.add(super.renderDirect());
		return buf.toString();
    }
    
	function getItemInnerNode() : HtmlNodeElement
	{
		return innerNode;
	}
}
