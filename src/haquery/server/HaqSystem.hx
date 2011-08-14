package haquery.server;

import php.FileSystem;
import php.io.File;
import php.io.Path;
import php.Lib;
import php.Sys;
import php.Web;

import haquery.server.HaQuery;
import haquery.server.HaqComponent;
import haquery.server.HaqProfiler;
import haquery.server.HaqRoute;

class HaqSystem
{
    public function new(route:HaqRoute) : Void
    {
		var startTime = Date.now().getTime();

        trace(null);
        trace("HAQUERY START route.pagePath = " + route.path + ", HTTP_HOST = " + Web.getHttpHost() + ", clientIP = " + Web.getClientIP());

        HaqProfiler.begin('HaqSystem::init(): build components');
            var templates = new HaqTemplates(HaQuery.config.componentsFolders);
        HaqProfiler.end();
        
        HaQuery.isPostback = php.Web.getParams().get('HAQUERY_POSTBACK')!=null ? true : false;

		var params = php.Web.getParams();
        if (route.pageID != null)
		{
			params.set('pageID', route.pageID);
		}

        HaqProfiler.begin('HaqSystem::init(): page construct');
		var manager : HaqComponentManager = new HaqComponentManager(templates);
		var page : HaqPage = manager.createPage(route.path, params);
        HaqProfiler.end();

        var html : String;
        if (!HaQuery.isPostback)
        {
            html = renderPage(page, templates, manager, route.path);
        }
        else
        {
            html = renderAjax(page);
        }
        
        trace(StringTools.format("HAQUERY FINISH %.5f s", Date.now().getTime()-startTime));

        if (HaQuery.config.isTraceProfiler)
        {
            trace("profiler info:\n"+HaqProfiler.getResults());
            HaqProfiler.saveTotalResults();
        }

        Lib.print(html);
    }
    
    static function renderPage(page:HaqPage, templates:HaqTemplates, manager:HaqComponentManager, path:String) : String
    {
        HaqProfiler.begin('HaqSystem::init(): page render');
            page.forEachComponent('preRender');
            var html : String = page.render();
        HaqProfiler.end();

        HaqProfiler.begin('HaqSystem::init(): insert html and javascripts to <head>');
            var incCss = Lambda.map(templates.getStyleFilePaths(), function(path:String):String { return getCssLink(path); } ).join('\n        ');
            var incJs = [ getScriptLink('haquery/client/jquery.js'), getScriptLink('haquery/client/haquery.js') ].join('\n        ');
            
            //var reCloseHead = new EReg('\\s*</head>', '');
            //var closeHeadTagPos = reCloseHead.match(html) ?reCloseHead.matchedPos().pos : html.length;
            html = html.replace("{styles}", incCss);
            html = html.replace("{scripts}", incJs);
/*				.substr(0, closeHeadTagPos) 
                 + incCss
                 + 
                 + html.substr(closeHeadTagPos);*/
            
            // вставляем подключение js-скрипты компонентов и вызова инициализации HaQuery
            var reCloseBody = new EReg('\\s*</body>', '');
            var closeBodyTagPos = reCloseBody.match(html) ? reCloseBody.matchedPos().pos : html.length;
            
            html = html.substr(0, closeBodyTagPos)
                 + "\n\n"
                 + "        <script>\n"
                 + "            if(typeof haquery=='undefined') alert('haquery.js must be loaded!');\n"
                 + "            " + templates.getInternalDataForPageHtml().replace('\n','\n            ') + '\n'
                 + "            " + manager.getInternalDataForPageHtml(path).replace('\n', '\n            ') + '\n'
                 + "            haquery.base.HaQuery.run();\n"
                 + "        </script>\n"
                 + html.substr(closeBodyTagPos);
        HaqProfiler.end();

        php.Web.setHeader('Content-Type', page.contentType);
        
        return html;
    }
    
    function renderAjax(page : HaqPage)
    {
        page.forEachComponent('preEventHandlers');

        var controlID : String = php.Web.getParams().get('HAQUERY_ID');
        var componentID = '';
        var n = controlID.lastIndexOf(HaqInternals.DELIMITER);
        if (n>0)
        {
            componentID = controlID.substr(0, n);
            controlID = controlID.substr(n+1);
        }

        var component = page.findComponent(componentID);
        if (component==null) throw "Component id = '" + componentID + "' not found.";
        var handler = controlID + '_' + php.Web.getParams().get('HAQUERY_EVENT');
        Reflect.callMethod(component, handler, null);
        
        php.Web.setHeader('Content-Type', 'text/plain; charset=utf-8');
        
        return 'HAQUERY_OK' + HaqInternals.getAjaxAnswer();
    }
    
    static function getScriptLink(path:String) : String
    {
        var url = HaQuery.path2url(path) + '?' + FileSystem.stat(path).mtime.getTime();
        return "<script src='" + url + "'></script>";
    }
    
	static function getCssLink(path:String) : String
    {
        var url = HaQuery.path2url(path) + '?' + FileSystem.stat(path).mtime.getTime();
        return "<link rel='stylesheet' type='text/css' href='" + url + "' />";
    }
}
