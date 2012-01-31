package haquery.server;

import haxe.Unserializer;
import php.FileSystem;
import php.io.File;
import php.io.Path;
import php.Sys;
import haquery.server.Web;
import haquery.server.Lib;
import haquery.server.HaqComponent;
import haquery.server.HaqProfiler;
import haquery.server.HaqRoute;
import haquery.server.HaqDefines;

using haquery.StringTools;

class HaqSystem
{
    public function new(route:HaqRoute, isPostback:Bool) : Void
    {
        trace(null);
		
        Lib.profiler.begin("system");

            trace("HAQUERY SYSTEM Start route.pagePath = " + route.path + ", HTTP_HOST = " + Web.getHttpHost() + ", clientIP = " + Web.getClientIP() + ", pageID = " + route.pageID);
            
            Lib.profiler.begin('templates');
                var templates = new HaqTemplates(HaqConfig.getComponentsFolders("", Lib.config.componentsPackage));
            Lib.profiler.end();

            var params = php.Web.getParams();
            if (route.pageID != null)
            {
                params.set('pageID', route.pageID);
            }

            var manager : HaqComponentManager = new HaqComponentManager(templates);
            
            Lib.profiler.begin('createPage');
                var page = manager.createPage(route.path, params);
            Lib.profiler.end();

            var html : String;
            if (!isPostback)
            {
                html = renderPage(page, templates, manager, route.path);
            }
            else
            {
                html = renderAjax(page);
            }
            
            trace("HAQUERY SYSTEM Finish");

        Lib.profiler.end();
        
        Lib.print(html);
    }
    
    static function renderPage(page:HaqPage, templates:HaqTemplates, manager:HaqComponentManager, path:String) : String
    {
        Lib.profiler.begin('renderPage');
            page.forEachComponent('preRender');
            
            if (!Lib.config.disablePageMetaData)
            {
                page.insertStyles(templates.getStyleFilePaths().concat(manager.getRegisteredStyles()));
                page.insertScripts([ 'haquery/client/jquery.js', 'haquery/client/haquery.js' ].concat(manager.getRegisteredScripts()));
                page.insertInitInnerBlock(
                      "<script>\n"
                    + "    if(typeof haquery=='undefined') alert('haquery.js must be loaded!');\n"
                    + "    " + templates.getInternalDataForPageHtml().replace('\n','\n    ') + '\n'
                    + "    " + manager.getInternalDataForPageHtml(page, path).replace('\n', '\n    ') + '\n'
                    + "    haquery.client.Lib.run();\n"
                    + "</script>"
                );
            }
            
            var html : String = page.render();
        Lib.profiler.end();

        php.Web.setHeader('Content-Type', page.contentType);
        
        return html;
    }
    
    function renderAjax(page : HaqPage)
    {
        page.forEachComponent('preEventHandlers');

        var componentID = php.Web.getParams().get('HAQUERY_COMPONENT');
        var method = php.Web.getParams().get('HAQUERY_METHOD');
        
        var component : HaqComponent = page.findComponent(componentID);
        
		if (component != null)
		{
			if (Reflect.hasField(component, method))
			{
				if (!callElemEventHandler(component, method))
				{
					if (!callSharedMethod(component, method, Unserializer.run(php.Web.getParams().get('HAQUERY_PARAMS'))))
					{
						throw "Method '" + componentID + '#' + method + "' must be marked as @shared to be callable from the client.";
					}
				}
				
			}
			else
			{
				throw "Method '" + componentID + "#" + method + "' not found.";
			}
		}
		else
        {
            throw "Component id = '" + componentID + "' not found.";
        }
        
        php.Web.setHeader('Content-Type', 'text/plain; charset=utf-8');
        
        return 'HAQUERY_OK' + HaqInternals.getAjaxResponse();
    }
	
	function callElemEventHandler(component:HaqComponent, method:String) : Bool
	{
		var n = method.lastIndexOf("_");
		if (n >= 0)
		{
			var event = method.substr(n + 1);
			if (Lambda.has(HaqDefines.elemEventNames, event))
			{
				component.callElemEventHandler(method.substr(0, n), event);
				return true;
			}
		}
		return false;
	}
	
	function callSharedMethod(component:HaqComponent, method:String, params:Array<Dynamic>) : Bool
	{
		var haxeClass = Type.getClass(component);
		var meta = haxe.rtti.Meta.getFields(haxeClass);
		var m = Reflect.field(meta, method);
		if (Reflect.hasField(m, "shared"))
		{
			Reflect.callMethod(component, Reflect.field(component, method), params);
			return true;
		}
		
		return false;
	}
}
