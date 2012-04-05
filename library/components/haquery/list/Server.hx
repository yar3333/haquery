package components.haquery.list;

import haquery.HashTools;
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
				manager.createComponent(this, "listitem", Std.string(i), null, innerNode, false);
			}
        }
	}

	public function bind(models:Iterable<Dynamic>)
    {
        Lib.assert(!Lib.isPostback, "List binding on postback is not allowed.");
		
		var itemInnerNode = getItemInnerNode();
		
		var i = 0;
        for (model in models)
        {
            manager.createComponent(this, "listitem", Std.string(i), cast HashTools.hashify(model), itemInnerNode, true);
            i++;
        }
		q('#length').val(Std.string(i));
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
