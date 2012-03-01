package haquery.server;

import haxe.Serializer;
import haxe.Unserializer;

import haquery.server.Web;
import haquery.server.Lib;
import haquery.server.HaqDefines;

using haquery.StringTools;

class HaqSystem
{
	public static var page : HaqPage;
	
	static var ajaxResponse = "";

	public static function run(pageFullTag:String, pageID:String, isPostback:Bool)
	{
		new HaqSystem(pageFullTag, pageID, isPostback);
	}
	
	public static function addAjaxResponse(jsCode:String) 
	{
		ajaxResponse += jsCode + "\n";
	}
	
	function new(pageFullTag:String, pageID:String, isPostback:Bool)
    {
        trace(null);
		
        Lib.profiler.begin("system");

            trace("HAQUERY SYSTEM Start pageFullTag = " + pageFullTag #if php +  ", HTTP_HOST = " + Web.getHttpHost() #end + ", clientIP = " + Web.getClientIP() + ", pageID = " + pageID);
            
            var params = Web.getParams();
            if (pageID != null)
            {
                params.set('pageID', pageID);
            }

            Lib.profiler.begin('manager');
				var manager : HaqTemplateManager = new HaqTemplateManager();
            Lib.profiler.end();

            Lib.profiler.begin('page');
				manager.createPage(pageFullTag, params);
            Lib.profiler.end();
            
			var html : String;
            if (!isPostback)
            {
                html = renderPage(page);
            }
            else
            {
                html = processPostback(page);
            }
            
            trace("HAQUERY SYSTEM Finish");

        Lib.profiler.end();
        
        Lib.print(html);
    }
    
    function renderPage(page:HaqPage) : String
    {
        Lib.profiler.begin('renderPage');
            var html : String = page.render();
        Lib.profiler.end();

        Web.setHeader('Content-Type', page.contentType);
        
        return html;
    }
    
    function processPostback(page : HaqPage)
    {
        page.forEachComponent('preEventHandlers');

        var componentID = Web.getParams().get('HAQUERY_COMPONENT');
        var method = Web.getParams().get('HAQUERY_METHOD');
        
        var component = page.findComponent(componentID);
        
		var result = null;
		
		if (component != null)
		{
			var r = callElemEventHandler(component, method);
			if (!r.success)
			{
				r = callSharedMethod(component, method, Unserializer.run(Web.getParams().get('HAQUERY_PARAMS')));
			}
			if (r.success)
			{
				result = r.result;
			}
			else
			{
				throw "Method " + method + "() of the " + component.fullTag + " component's server class must exists and marked @shared to be callable from the client.";
			}
		}
		else
        {
            throw "Component id = '" + componentID + "' not found.";
        }
        
        Web.setHeader('Content-Type', 'text/plain; charset=utf-8');
        
        return 'HAQUERY_OK' + Serializer.run(result) + "\n" + ajaxResponse;
    }
	
	function callElemEventHandler(component:HaqComponent, method:String) : { success:Bool, result:Dynamic }
	{
		var n = method.lastIndexOf("_");
		if (n >= 0)
		{
			var event = method.substr(n + 1);
			if (Lambda.has(HaqDefines.elemEventNames, event))
			{
				return { success:true, result:component.callElemEventHandler(method.substr(0, n), event) };
			}
		}
		return { success:false, result:null };
	}
	
	function callSharedMethod(component:HaqComponent, method:String, params:Array<Dynamic>) : { success:Bool, result:Dynamic }
	{
		var haxeClass = Type.getClass(component);
		var meta = haxe.rtti.Meta.getFields(haxeClass);
		var m = Reflect.field(meta, method);
		if (Reflect.hasField(m, "shared"))
		{
			return { success:true, result:Reflect.callMethod(component, Reflect.field(component, method), params) };
		}
		return { success:false, result:null };
	}
}
