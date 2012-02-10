package haquery.components.list;

import haquery.HashTools;
import haquery.server.Lib;

using haquery.StringTools;

class Server extends Base
{
    override function createChildComponents():Void 
	{
        if (Lib.isPostback)
        {
			for (i in 0...length)
			{
				manager.createComponent(this, 'haq:listitem', Std.string(i), null, parentNode);
			}
        }
	}

    public function bind(constsList:Iterable<Dynamic>)
    {
        Lib.assert(!Lib.isPostback, 'List binding on postback is not allowed.');
	
		var i = 0;
        for (consts in constsList)
        {
            manager.createComponent(this, 'haq:listitem', Std.string(i), cast HashTools.hashify(consts), parentNode);
            i++;
        }
		q('#length').val(Std.string(i));
    }
    
    override function render()
    {
        var r = '';
		for (component in components)
        {
            r += component.render().trim() + "\n";
        }
        return super.render() + '\n' + r;
    }
}
