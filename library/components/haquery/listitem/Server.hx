package components.haquery.listitem;

import haquery.server.Lib;
import haquery.server.HaqComponent;
import htmlparser.HtmlDocument;
import htmlparser.HtmlNodeElement;

class Server extends Base
{
	override public function construct(fullTag:String, parent:HaqComponent, id:String, doc:HtmlNodeElement, _params:Dynamic, innerNode:HtmlNodeElement, isInnerComponent:Bool):Void 
	{
        var params = (cast _params : Map<String,Dynamic>);
		
		var html : String;
		
		#if profiler Profiler.begin("listitem.applyHtmlParams"); #end
		html = Tools.applyHtmlParams(innerNode.innerHTML, params);
		#if profiler Profiler.end(); #end
		
		var htmlDoc : HtmlDocument;
		
		#if profiler Profiler.begin("listitem.newHtmlDocument"); #end
		htmlDoc = new HtmlDocument(html);
		#if profiler Profiler.end(); #end
		
		super.construct(fullTag, parent, id, htmlDoc, params, null, isInnerComponent);
	}
    
	override function createChildComponents()
	{
		if (doc != null)
		{
			Lib.manager.createDocComponents(this, doc, false);
		}
		
		callMethodForEach("preInit", true);
		callMethodForEach("init", false);		
	}
	
	override function callElemEventHandler(elemID:String, eventName:String) : Dynamic
    {
        if (parent != null && parent.parent != null)
        {
            var handler = elemID + '_' + eventName;
            return Reflect.callMethod(parent.parent, Reflect.field(parent.parent, handler), [ this, null ]);
        }
		return null;
    }
}
