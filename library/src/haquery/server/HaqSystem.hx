package haquery.server;

import php.FileSystem;
import php.io.File;
import php.io.Path;
import php.Sys;
import php.Web;
import haquery.server.Lib;
import haquery.server.HaqComponent;
import haquery.server.HaqProfiler;
import haquery.server.HaqRoute;
using haquery.StringTools;


class HaqSystem
{
    /**
     * Ajax?
     *   false => rendering HTML;
     *   true => calling server event handler.
     */
    static public var isPostback(default, null) : Bool;
    
    public function new(route:HaqRoute) : Void
    {
        trace(null);
		
        Lib.profiler.begin("system");

            trace("HAQUERY SYSTEM Start route.pagePath = " + route.path + ", HTTP_HOST = " + Web.getHttpHost() + ", clientIP = " + Web.getClientIP() + ", pageID = " + route.pageID);

            isPostback = php.Web.getParams().get('HAQUERY_POSTBACK')!=null ? true : false;
            
            Lib.profiler.begin('templates');
                var templates = new HaqTemplates(Lib.config.getComponentsFolders());
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
            
            page.insertStyles(templates.getStyleFilePaths().concat(manager.getRegisteredStyles()));
            page.insertScripts([ 'haquery/client/jquery.js', 'haquery/client/haquery.js' ].concat(manager.getRegisteredScripts()));
            page.insertInitInnerBlock(
                  "<script>\n"
                + "    if(typeof haquery=='undefined') alert('haquery.js must be loaded!');\n"
                + "    " + templates.getInternalDataForPageHtml().replace('\n','\n    ') + '\n'
                + "    " + manager.getInternalDataForPageHtml(path).replace('\n', '\n    ') + '\n'
                + "    haquery.client.Lib.run();\n"
                + "</script>"
            );
            
            var html : String = page.render();
        Lib.profiler.end();

        php.Web.setHeader('Content-Type', page.contentType);
        
        return html;
    }
    
    function renderAjax(page : HaqPage)
    {
        page.forEachComponent('preEventHandlers');

        var fullElemID : String = php.Web.getParams().get('HAQUERY_ID');
        var n = fullElemID.lastIndexOf(HaqInternals.DELIMITER);
        var componentID = n > 0 ? fullElemID.substr(0, n) : '';
        var elemID = n > 0 ? fullElemID.substr(n+1) : fullElemID;
        
        var component : HaqComponent = page.findComponent(componentID);
        if (component == null)
        {
            throw "Component id = '" + componentID + "' not found.";
        }
        
        component.callElemEventHandler(elemID, php.Web.getParams().get('HAQUERY_EVENT'));
        
        php.Web.setHeader('Content-Type', 'text/plain; charset=utf-8');
        
        return 'HAQUERY_OK' + HaqInternals.getAjaxResponse();
    }
}
