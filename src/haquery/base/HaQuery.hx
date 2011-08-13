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
	import php.FirePHP;
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
		 pages : 'pages/'
		,support : 'support/'
		,temp : 'temp/'
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
			loadBootstraps(route.pagePath);
			
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
				FileSystem.setCurrentDirectory(Path.directory(route.pagePath));
				untyped __call__('require', Path.withoutDirectory(route.pagePath));
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

    /*static public function error(message:String, ?pos : haxe.PosInfos)
    {
		#if php
			var stack : Array<NativeArray> = untyped Lib.toHaxeArray(untyped __call__('debug_backtrace'));

			var frow = Lib.hashOfAssociativeArray(stack.shift());
			
			var text = "\n"
					 + "\t in class <b>" + pos.className + "</b> in file <b>" + pos.fileName + "</b> at line <b>" + pos.lineNumber + "</b>\n"
					 + "\t in <b>" + frow.get('file') + "</b> at line <b>" + frow.get('line') + "</b>\n"
					 + "Stack trace:\n";

			for (nrow in stack)
			{
				var row : Hash<Dynamic> = Lib.hashOfAssociativeArray(nrow);
				text+= "\t<b>";
				if (row.exists('class')) text+= row.get('class')+row.get('type')+row.get('function');
				else                     text+= row.get('function');

				if (row.exists('file'))
				{
					text+= "</b> in <b>" + row.get('file') + "</b> at line <b>" + row.get('line') + "</b>\n";
					var args = '';
					if (row.exists('args'))
					{
						var argsArray = Lib.toHaxeArray(row.get('args'));
						//if (argsArray.length >= 4)
						//{
						//	var args3 : Array<Dynamic> = Lib.toHaxeArray(argsArray[3]);
						//	if (args3!=null) args = args3.join("\n\t\t");
						//}
					}
					text+= args!='' ? "\t\t" + args + "\n" : '';
				}
				else
					text += "\n";
			}

			HaQuery.trace("ERROR: " + message + StringTools.stripTags(text));
			Lib.print(StringTools.replace(StringTools.replace("HAQUERY <b>ERROR:</b> "+StringTools.htmlEscape(message)+text, "\n", '<br />'), "\t", '&nbsp;&nbsp;&nbsp;&nbsp;'));
			
			Sys.exit(1);
		#else
			var stack : String = untyped __js__("(new Error()).stack");
			stack = stack.substr(stack.indexOf('\n')+1);
			stack = stack.substr(stack.indexOf('\n')+1);
			throw message + "\nStack trace:\n" + stack;
		#end
    }*/
	
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
				//trace('loadBootstraps: ' + className);
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
			if (Type.getClassName(Type.getClass(v)) == 'String') text = v;
			else
			if (!isNull(v))
			{
				text = "DUMP " + pos.fileName + ":" + pos.lineNumber + "\n";
				var dump = ''; untyped __php__("ob_start(); var_dump($v); $dump = ob_get_clean();");
				text += dump;
			}

			var tempDir = HaQuery.folders.temp;
			if (!FileSystem.exists(tempDir))
			{
				FileSystem.createDirectory(tempDir);
			}
			
			if (text != '')
			{
				var isHeadersSent : Bool = untyped __call__('headers_sent');
				if (!isHeadersSent)
				{
					FirePHP.getInstance(true).trace(text);
				}
				else
				{
					Lib.println("<script>if (console) console.debug(decodeURIComponent(\"" + StringTools.urlEncode(text) + "\"));</script>");
				}
			}
			
			var f : FileOutput = php.io.File.append(tempDir + "haquery.log", false);
			if (f != null)
			{
				f.writeString(text != null ? StringTools.format('%.3f', Date.now().getTime() - startTime) + " HAQUERY " + StringTools.replace(text, "\n", "\n\t") + "\n" : "\n");
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
			Sys.exit(1);
		}
	#end
}
