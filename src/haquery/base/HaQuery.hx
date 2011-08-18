package haquery.base;

import haxe.Stack;

#if php
	import php.Lib;
	import php.Web;
	import php.Sys;
	import php.NativeArray;
	import php.Session;
	import php.FileSystem;
	import php.io.FileOutput;
	import php.io.Path;
	import php.firePHP.FirePHP;
	import haquery.server.HaqInternals;
	import haquery.server.HaqConfig;
	import haquery.server.HaqRoute;
	import haquery.server.HaqBootstrap;
	import haquery.server.HaqSystem;
	import haquery.server.db.HaqDb;
#else
	import haxe.Firebug;
	import js.Lib;
	import haquery.client.HaqInternals;
	import haquery.client.HaqSystem;
#end

class HaQuery
{
	public static inline var VERSION = 2.1; 
	
	public static inline var folders = {
		 pages : 'pages'
		,support : 'support'
		,temp : 'temp'
	};
	
	#if php
		public static var config : HaqConfig = new HaqConfig();

		/**
		 * Признак пришедших через ajax данных.
		 * Говорит о том, что требуется в данном запросе:
		 *  - false - выдать HTML (если произошло просто обращение к странице);
		 *  - true - обработать данные (если происходит вызов серверного обработчика события).
		 */
		public static var isPostback : Bool = false;
	   
		static var startTime : Float;
	#end

    static public function run() : Void
    {
		#if php
			startTime = Date.now().getTime();
			haxe.Log.trace = HaQuery.trace;
			
			var route = new HaqRoute(Web.getParams().get('route'));
			loadBootstraps(route.path);
			
			if (HaQuery.config.autoSessionStart)
			{
				Session.start();
			}

			if (config.autoDatabaseConnect && config.db.type!=null)
			{
				HaqDb.connect(HaQuery.config.db);
			}
			
			if (route.routeType == HaqRouteType.file)
			{
				FileSystem.setCurrentDirectory(Path.directory(route.path));
				untyped __call__('require', Path.withoutDirectory(route.path));
			}
			else
			{
				var system = new HaqSystem(route);
			}
		#else
			if (Firebug.detect()) Firebug.redirectTraces();
			var system = new HaqSystem();
		#end
    }
	
    static public function redirect(url:String) : Void
    {
        #if php
			if (HaQuery.isPostback) HaqInternals.addAjaxAnswer("window.location.href = '" + HaQuery.jsEscape(url) + "';");
			else                    php.Web.redirect(url);
		#else
			if (url == Lib.window.location.href) Lib.window.location.reload(true);
			else Lib.window.location.href = url;
		#end
    }

	static public function reload() : Void
	{
		#if php
			if (HaQuery.isPostback) HaqInternals.addAjaxAnswer("window.location.reload(true);");
			else					redirect(php.Web.getURI());
		
		#else
			Lib.window.location.reload(true);
		#end
	}

	#if debug
		static public function assert(e:Bool, errorMessage:String=null, ?pos : haxe.PosInfos) : Void
		{
			if (!e) 
			{
				if (errorMessage == null) errorMessage = "ASSERT";
				throw errorMessage + " in " + pos.fileName + ' at line ' + pos.lineNumber;
			}
		}
	#else
		static public inline function assert(e:Bool, errorMessage:String=null, ?pos : haxe.PosInfos) : Void
		{
		}
	#end
	
	#if php
		/**
		 * Загружает файлы bootstrap.php, которые ищет в папках начиная от текущей и до $relativePath.
		 * @param type $relativePath
		 */
		private static function loadBootstraps(relativePath:String) : Void
		{
			var folders = StringTools.trim(relativePath, '/').split('/');
			for (i in 0...folders.length)
			{
				var className = folders.slice(0,i).join('.') + '.Bootstrap';
				var clas : Class<HaqBootstrap> = untyped Type.resolveClass(className);
				if (clas != null)
				{
					var b : HaqBootstrap = Type.createInstance(clas, []);
					b.init(config);
				}
			}
		}
		
		/**
		 * Преобразует дисковый путь (path) в виртуальный (url).
		 * @param string $path
		 * @return string
		 */
		static public function path2url(path:String) : String
		{   
			var realPath = FileSystem.fullPath('').replace("\\", '/') + '/' + path.trim('/\\');
			var rootPath:String = StringTools.replace(Web.getDocumentRoot(), "\\", '/');
			if (!StringTools.startsWith(realPath, rootPath))
			{
				throw "Can't resolve path '" + path + "' with realPath = '" + realPath + "' and rootPath = '" + rootPath + "'.";
			}
			var n = rootPath.length;
			var s = realPath.substr(n);
			return '/' + s.ltrim('/');
		}
		
		static public function jsEscape(s:String) : String
		{
			return untyped __call__('addcslashes', s, "\'\"\t\r\n\\");
		}
		
		static function isNull(e:Dynamic) : Bool
		{
			return untyped __physeq__(e, null);
		}
		
		static function trace(v:Dynamic, ?pos : haxe.PosInfos) : Void
		{
			if (HaQuery.config.filterTracesByIP!='')
			{
				if (HaQuery.config.filterTracesByIP!=Web.getClientIP()) return;
			}
			
			var text = '';
			if (Type.getClassName(Type.getClass(v)) == 'String') text += v;
			else
			if (!isNull(v))
			{
				text += "DUMP\n";
				var dump = ''; untyped __php__("ob_start(); var_dump($v); $dump = ob_get_clean();");
				text += StringTools.stripTags(dump);
			}

			if (text != '')
			{
                var isHeadersSent : Bool = untyped __call__('headers_sent');
                if (!isHeadersSent)
				{
					try
                    {
                        if (text.startsWith('HAXE EXCEPTION'))
                        {
                            FirePHP.getInstance(true).error(text);
                        }
                        else if (text.startsWith('HAQUERY'))
                        {
                            FirePHP.getInstance(true).info(text);
                        }
                        else
                        {
                            text = pos.fileName + ":" + pos.lineNumber + " : " + text;
                            FirePHP.getInstance(true).warn(text);
                        }
                    }
                    catch (s:String)
                    {
                        text += "\n\nFirePHP exception: " + s;
                    }
				}
				else
				{
					Lib.println("<script>if (console) console.debug(decodeURIComponent(\"" + StringTools.urlEncode("SERVER " + text) + "\"));</script>");
				}
			}
			
			if (!FileSystem.exists(HaQuery.folders.temp))
			{
				FileSystem.createDirectory(HaQuery.folders.temp);
			}
            
			var f : FileOutput = php.io.File.append(HaQuery.folders.temp + "/haquery.log", false);
			if (f != null)
			{
				f.writeString(text != '' ? StringTools.format('%.3f', Date.now().getTime() - startTime) + " " + StringTools.replace(text, "\n", "\n\t") + "\n" : "\n");
				f.close();
			}
		}
		
		public static function traceException(e:Dynamic) : Void
		{
			var text = "HAXE EXCEPTION: " + Std.string(e) + "\n"
					 + "Stack trace:" + Stack.toString(Stack.exceptionStack()).replace('\n', '\n\t');
			var nativeStack : Array<Hash<Dynamic>> = php.Stack.nativeExceptionStack();
			assert(nativeStack != null);
			text += "\n\n";
			text += "NATIVE EXCEPTION: " + Std.string(e) + "\n";
			text += "Stack trace:\n";
			for (row in nativeStack)
			{
				text += "\t";
				if (row.exists('class')) text += row.get('class') + row.get('type');
				text += row.get('function');

				if (row.exists('file'))
				{
					text += " in " + row.get('file') + " at line " + row.get('line') + "\n";
				}
				else
					text += "\n";
			}
			trace(text);
			//Sys.exit(1);
		}
	#end
}
