package haquery.server;

import haxe.htmlparser.HtmlNodeElement;
import haxe.htmlparser.HtmlNodeText;
import haquery.common.HaqDefines;
import haquery.server.HaqComponent;
import haquery.server.FileSystem;
import haquery.server.Lib;
import haquery.common.HaqCookie;
using haquery.StringTools;

class HaqPage extends HaqComponent
{
	/**
	 * Default value is "text/html; charset=utf-8".
	 */
    public var contentType = "text/html; charset=utf-8";
    
    /**
     * Last unexist URL part will be placed to this var. 
     * For example, if your request "http://site.com/news/123"
     * then pageID will be "123".
     */
    public var pageID : String;
	
    /**
     * Disable special CSS and JS inserts to your HTML pages.
     */
	public var disableSystemHtmlInserts : Bool;
	
	override public function render() : String 
	{
        Lib.profiler.begin("preRender");
		forEachComponent('preRender');
        Lib.profiler.end();
		
		if (!disableSystemHtmlInserts)
		{
			insertStyles(manager.getRegisteredStyles());
			insertScripts([ 'haquery/client/jquery.js', HaqDefines.haqueryClientFilePath ].concat(manager.getRegisteredScripts()));
			insertInitBlock(
				  "<script>\n"
				+ "    if(typeof haquery=='undefined') alert('" + HaqDefines.haqueryClientFilePath + " must be loaded!');\n"
				+ "    " + manager.getDynamicClientCode(this).replace('\n', '\n    ') + '\n'
				+ "</script>"
			);
		}
		
		return super.render();
	}
    
    function insertStyles(links:Array<String>)
    {
        var text = Lambda.map(links, function(path) return getStyleLink(path)).join("\n");
        var heads = doc.find(">html>head");
        if (heads.length > 0)
        {
            var head : HtmlNodeElement = heads[0];
            var child : HtmlNodeElement = null;
            if (head.children.length > 0)
            {
                child = head.children[0];
                while (child != null && child.name != "link" && (child.getAttribute("rel") != "stylesheet" || child.getAttribute("type") != "text/css"))
                {
                    child = child.getNextSiblingElement();
                }
            }
            head.addChild(new HtmlNodeText(text + "\n"), child);
        }
        else
        {
            doc.addChild(new HtmlNodeText(text + "\n"));
        }
    }
    
    function insertScripts(links:Array<String>)
    {
        var text = Lambda.map(links, function(path) return getScriptLink(path)).join("\n");
        var heads = doc.find(">html>head");
        if (heads.length > 0)
        {
            var head : HtmlNodeElement = heads[0];
            var child : HtmlNodeElement = null;
            if (head.children.length > 0)
            {
                child = head.children[0];
                while (child != null && child.name != "script")
                {
                    child = child.getNextSiblingElement();
                }
            }
            head.addChild(new HtmlNodeText(text + "\n"), child);
        }
        else
        {
            doc.addChild(new HtmlNodeText(text + "\n"));
        }
    }
    
    function insertInitBlock(text:String)
    {
        var bodyes = doc.find(">html>body");
        if (bodyes.length > 0)
        {
            var body = bodyes[0];
            body.addChild(new HtmlNodeText("\n        " + text.replace('\n', '\n        ') + '\n    '));
        }
        else
        {
            doc.addChild(new HtmlNodeText("\n" + text + '\n'));
        }
    }
    
    function getScriptLink(url:String) : String
    {
		if (url == null) return "";
		
		if (url.startsWith("<")) return url;
		
		if (!url.startsWith("http://") && !url.startsWith("/"))
		{
			url += "?" + FileSystem.stat(url).mtime.getTime() / 1000;
			url = "/" + url;
		}
		
		return "<script src='" + url + "'></script>";
    }
    
	function getStyleLink(url:String) : String
    {
		if (url == null) return "";
		
		if (url.startsWith("<")) return url;
		
		if (!url.startsWith("http://") && !url.startsWith("/"))
		{
			url += "?" + FileSystem.stat(url).mtime.getTime() / 1000;
			url = '/' + url;
		}
		
        return "<link rel='stylesheet' type='text/css' href='" + url + "' />";
    }

	public var config : HaqConfig;
	public var cookie : HaqCookie;
    public var profiler : HaqProfiler;
	public var db : HaqDb;
    /**
     * Ajax ? calling server event handler : rendering HTML.
     */
    public var isPostback(default, null) : Bool;
    
	var params_cached : Hash<String>;
	public var params(params_getter, null) : Hash<String>;
	
	var uploadedFiles_cached : Hash<HaqUploadedFile>;
	public var uploadedFiles(uploadedFiles_getter, null) : Hash<HaqUploadedFile>;
	
	var ajaxResponse : String;
	
	var startTime : Float;
    
    public static function run(route:HaqRoute, bootstraps:Array<HaqBootstrap>) : Void
    {
		ajaxResponse = "";
		params_cached = null;
		uploadedFiles_cached = null;
		db = null;
		cookie = null;
		
		config = new HaqConfig("config.xml");
		
		try
        {
			startTime = Sys.time();
			runApplicationPage(route, bootstraps);
        }
		catch (e:Dynamic)
        {
			if (db != null)
			{
				db.close();
			}
			Exception.rethrow(e);
        }
    }
	
	function runApplicationPage(route:HaqRoute, bootstraps:Array<HaqBootstrap>) : Void
	{
		profiler = new HaqProfiler(config.enableProfiling);
		
		profiler.begin("HAQUERY");
		
			if (config.databaseConnectionString != null && config.databaseConnectionString != "")
			{
				db = new HaqDb(config.databaseConnectionString, config.sqlLogLevel, profiler);
			}
			
			isPostback = !isCli() && params.get('HAQUERY_POSTBACK') != null;
			
			cookie = new HaqCookie();
			
			for (bootstrap in bootstraps)
			{
				bootstrap.start();
			}
			
			if (manager == null)
			{
				profiler.begin('manager');
					manager = new HaqTemplateManager();
				profiler.end();
			}
			
			if (route.pageID != null)
			{
				params.set("pageID", route.pageID);
			}
			
			profiler.begin("page");
				trace("HAQUERY START " + (isCli() ? "CLI" : "WEB") + " pageFullTag = " + route.fullTag +  ", HTTP_HOST = " + getHttpHost() + ", clientIP = " + getClientIP() + ", pageID = " + route.pageID);
				page = manager.createPage(route.fullTag, !isCli() ? params : new Hash<String>());
				if (!isPostback)
				{
					var html = page.render();
					trace("HAQUERY FINISH");
					if (!isRedirected)
					{
						Web.setHeader('Content-Type', page.contentType);
						print(html);
					}
				}
				else
				{
					page.forEachComponent('preEventHandlers');
					var componentID = params.get('HAQUERY_COMPONENT');
					var component = page.findComponent(componentID);
					if (component != null)
					{
						var result = HaqComponentTools.callMethod(component, params.get('HAQUERY_METHOD'), Unserializer.run(params.get('HAQUERY_PARAMS')));
						trace("HAQUERY FINISH");
						Web.setHeader('Content-Type', 'text/plain; charset=utf-8');
						print('HAQUERY_OK' + Serializer.run(result) + "\n" + ajaxResponse);
					}
					else
					{
						throw new Exception("Component id = '" + componentID + "' not found.");
					}
				}
			profiler.end();
			
			bootstraps.reverse();
			for (bootstrap in bootstraps)
			{
				bootstrap.finish();
			}
			
			if (db != null)
			{
				db.close();
			}
		
		profiler.end();
		profiler.traceResults();		
	}
	
	
	function params_getter() : Hash<String>
	{
		if (params_cached == null)
		{
			fillParamsAndUploadedFiles();
		}
		return params_cached;
	}
	
	function uploadedFiles_getter() : Hash<HaqUploadedFile>
	{
		if (uploadedFiles_cached == null)
		{
			fillParamsAndUploadedFiles();
		}
		return uploadedFiles_cached;
	}
	
	function fillParamsAndUploadedFiles()
	{
		if (!isCli())
		{
			params_cached = Web.getParams();
			uploadedFiles_cached = new Hash<HaqUploadedFile>();
			
			#if php
			
			var nativeFiles : Hash<php.NativeArray> = php.Lib.hashOfAssociativeArray(untyped __var__("_FILES"));
			for (id in nativeFiles.keys())
			{
				var file : php.NativeArray = nativeFiles.get(id);
				uploadedFiles_cached.set(id, new HaqUploadedFile(
					 file[untyped "tmp_name"]
					,file[untyped "name"]
					,file[untyped "size"]
					,Type.createEnumIndex(HaqUploadError, file[untyped "error"])
				));
			}
			
			#elseif neko
			
			var lastPartName : String = null;
			var lastFileName : String = null;
			var lastTempFileName : String = null;
			var lastParamValue : String = null;
			var error : HaqUploadError = null;
			
			var maxUploadDataSize = config.maxPostSize;
			
			Web.parseMultipart(
				function(partName:String, fileName:String)
				{
					if (partName != lastPartName)
					{
						if (lastPartName != null)
						{
							if (lastFileName != null)
							{
								trace("set = " + lastPartName + ", " + lastFileName);
								uploadedFiles_cached.set(
									lastPartName
								   ,new HaqUploadedFile(lastTempFileName, lastFileName, FileSystem.stat(lastTempFileName).size, error)
								);
							}
							else
							{
								params_cached.set(lastPartName, lastParamValue);
							}
						}
						
						lastPartName = partName;
						lastFileName = fileName;
						lastTempFileName = getTempUploadedFilePath();
						lastParamValue = "";
						error = HaqUploadError.OK;
					}
				}
			   ,function(data:Bytes, offset:Int, length:Int)
				{
					if (lastFileName != null)
					{
						maxUploadDataSize -= length;
						if (maxUploadDataSize >= 0)
						{
							var h = File.append(lastTempFileName);
							h.writeBytes(data, 0, length);
							h.close();
						}
						else
						{
							error = HaqUploadError.INI_SIZE;
							if (FileSystem.exists(lastTempFileName))
							{
								FileSystem.deleteFile(lastTempFileName);
							}
						}
					}
					else
					{
						lastParamValue += data.readString(0, length);
					}
				}
			);
			
			if (lastPartName != null)
			{
				if (lastFileName != null)
				{
					uploadedFiles_cached.set(
						lastPartName
					   ,new HaqUploadedFile(lastTempFileName, lastFileName, FileSystem.stat(lastTempFileName).size, error)
					);
				}
				else
				{
					params_cached.set(lastPartName, lastParamValue);
				}
			}
			
			#end
		}
		else
		{
			params_cached = HaqCli.getParams();
			uploadedFiles_cached = new Hash<HaqUploadedFile>();
		}
	}
	
	function getTempUploadedFilePath()
	{
		var s = Std.string(Sys.time() * 1000);
		if (s.indexOf(".") >= 0) s = s.substr(0, s.indexOf("."));
		s += "_" + Std.int(Math.random() * 999999);
		s += "_" + Std.int(Math.random() * 999999);
		
		var tempDir = getCwd() + "/" + HaqDefines.folders.temp;
		if (!FileSystem.exists(tempDir))
		{
			FileSystem.createDirectory(tempDir);
		}
		
		var uploadsDir = tempDir + "/uploads";
		if (!FileSystem.exists(uploadsDir))
		{
			FileSystem.createDirectory(uploadsDir);
		}
		
		return uploadsDir + "/" + s;
	}
	
	public inline function addAjaxResponse(jsCode:String) 
	{
		ajaxResponse += jsCode + "\n";
	}
}
