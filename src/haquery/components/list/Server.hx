package haquery.components.list;

import php.Lib;
import php.Web;
import haquery.server.HaqComponentManager;
import haquery.server.HaqInternals;
import haquery.server.HaqTemplates;
import haquery.server.HaQuery;
import haquery.server.HaqXml;

import haquery.server.HaqComponent;
import haquery.server.HaqEvent;

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
				trace("createComponent haq:listitem " + Std.string(i));
				manager.createComponent(this, 'haq:listitem', Std.string(i), null, innerHTML);
			}
        }
	}

    public function bind(constsList:Array<Dynamic>)
    {
        HaQuery.assert(!HaQuery.isPostback, 'List binding on postback is not allowed.');
	
		for (i in 0...constsList.length)
        {
			manager.createComponent(this, 'haq:listitem', Std.string(i), constsList[i], innerHTML);
        }
		q('#length').val(Std.string(constsList.length));
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
