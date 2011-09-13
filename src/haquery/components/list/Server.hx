package haquery.components.list;

import haquery.server.HaQuery;
import haquery.server.HaqComponent;
using haquery.StringTools;

class Server extends HaqComponent
{
	override private function createChildComponents():Void 
	{
        if (HaQuery.isPostback)
        {
			var length = Std.parseInt(q('#length').val());
			trace('length = ' + length);
			for (i in 0...length)
			{
				manager.createComponent(this, 'haq:listitem', Std.string(i), null, innerHTML);
			}
        }
	}

    public function bind(constsList:Iterable<Dynamic>)
    {
        HaQuery.assert(!HaQuery.isPostback, 'List binding on postback is not allowed.');
	
		var i = 0;
        for (consts in constsList)
        {
			manager.createComponent(this, 'haq:listitem', Std.string(i), consts, innerHTML);
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
