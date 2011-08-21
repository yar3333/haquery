package components.list;

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

    public function bind(params:Array<Hash<Hash<String>>>)
    {
        HaQuery.assert(!HaQuery.isPostback, 'Call bind on postback is not allowed.');
	
		for (i in 0...params.length)
        {
			var p = new Hash<String>(); 
			p.set('seralizedParams', Lib.serialize(params[i]));
			manager.createComponent(this, 'haq:listitem', Std.string(i), p, innerHTML);
        }
		q('#length').val(Std.string(params.length));
    }
    
    override function render()
    {
        var r = '';
		for (component in components) r += component.render().trim() + "\n";
        return super.render() + '\n' + r;
    }
}
