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
            
            page.insertStyles(templates.getStyleFilePaths().concat(manager.getRegisteredStyles()));
            page.insertScripts([ 'haquery/client/jquery.js', 'haquery/client/haquery.js' ].concat(manager.getRegisteredScripts()));
            page.insertInitInnerBlock(
                  "<script>\n"
                + "    if(typeof haquery=='undefined') alert('haquery.js must be loaded!');\n"
                + "    " + templates.getInternalDataForPageHtml().replace('\n','\n    ') + '\n'
                + "    " + manager.getInternalDataForPageHtml(path).replace('\n', '\n    ') + '\n'
                + "    haquery.base.HaQuery.run();\n"
                + "</script>"
            );
            
            var html : String = page.render();
        HaqProfiler.end();

        php.Web.setHeader('Content-Type', page.contentType);
        
        return html;
    }
    
    function renderAjax(page : HaqPage)
    {
        page.forEachComponent('preEventHandlers');

        var controlID : String = php.Web.getParams().get('HAQUERY_ID');
        var component : HaqComponent = page;
        var n = controlID.lastIndexOf(HaqInternals.DELIMITER);
        if (n>0)
        {
            var componentID = controlID.substr(0, n);
            component = page.findComponent(componentID);
            if (component == null)
            {
                throw "Component id = '" + componentID + "' not found.";
            }
            controlID = controlID.substr(n+1);
        }
        component.callElemEventHandler(controlID, php.Web.getParams().get('HAQUERY_EVENT'));
        
        php.Web.setHeader('Content-Type', 'text/plain; charset=utf-8');
        
        return 'HAQUERY_OK' + HaqInternals.getAjaxAnswer();
    }
}
