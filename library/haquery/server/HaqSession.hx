package haquery.server;

import haxe.Serializer;
import haxe.Unserializer;
import stdlib.FileSystem;
import sys.io.File;
using StringTools;

class HaqSession
{
	var page : HaqPage;
	
	/**
	 * Chance to start garbage collection on session start. Between 0 and 1.
	 * Default is 0.01.
	 */
	public var gcStartChance = 0.01;
	
	/**
	 * Max session file life time in seconds.
	 * Default is 1 day.
	 */
	public var gcMaxLifeTime = 60 * 60 * 24;
	
	var savePath = "temp/sessions";
	
	var started = false;
	var sessionName = "NEKOSESSIONID";
	
	public var id(default, null) : String;
	
	var sessionData : Hash<Dynamic>;
	var needSave = false;

	public function new(page:HaqPage)
	{
		this.page = page;
	}

	public function setSavePath(path:String) : Void
	{
		path = path.replace("\\", "/");
		if (path.endsWith("/"))
		{
			path = path.substr(0, path.length - 1);
		}
		savePath = path;
	}
	
	public function get(name:String) : Dynamic
	{
		start();
		return sessionData.get(name);
	}

	public function set(name:String, value:Dynamic)
	{
		start();
		needSave = true;
		sessionData.set(name, value);
	}

	public function exists(name:String)
	{
		start();
		return sessionData.exists(name);
	}

	public function remove(name:String)
	{
		start();
		needSave = true;
		sessionData.remove(name);
	}

	public function clear()
	{
		sessionData = new Hash<Dynamic>();
		started = true;
		needSave = true;
		commit();
	}
	
	function start()
	{
		if (started) return;
		
		started = true;
		needSave = false;
		
		if (!FileSystem.exists(savePath))
		{
			FileSystem.createDirectory(savePath);
		}
		
		if (Math.random() < gcStartChance)
		{
			collectGarbage();
		}
		
		id = page.cookie.get(sessionName);

		if (id != null)
		{
			if (~/^[a-zA-Z0-9]+$/.match(id))
			{
				var file = savePath + "/" + id + ".sess";
				if (!FileSystem.exists(file))
				{
					id = null;
				}
				else
				{
					var fileData = try File.getContent(file) catch ( e:Dynamic ) null;
					if (fileData == null)
					{
						id = null;
						try FileSystem.deleteFile(file) catch( e:Dynamic ) null;
					}
					else
					{
						sessionData = Unserializer.run(fileData);
					}
				}
			}
			else 
			{
				id = null;	
			}
		}
		
		if (id == null)
		{
			sessionData = new Hash<Dynamic>();
			
			while (true)
			{
				id = haxe.Md5.encode(Std.string(Date.now().getTime()) + Std.string(Std.random(10000)) + Std.string(Std.random(10000)));
				if (!FileSystem.exists(savePath + "/" + id + ".sess")) break;
			}
			
			page.cookie.set(sessionName, id, null, "/");
			
			needSave = true;
			commit();
		}
	}

	public function commit()
	{
		if (started && needSave)
		{
			try
			{
				File.saveContent(savePath + "/" + id + ".sess", Serializer.run(sessionData));
				needSave = false;
			}
			catch (e:Dynamic)
			{
				// Session is gone, ignore it.
			}
		}
	}
	
	function collectGarbage()
	{
		var nowTime = Date.now().getTime();
		var maxLifeTimeMS = gcMaxLifeTime * 1000;
		
		for (file in FileSystem.readDirectory(savePath))
		{
			if (nowTime - FileSystem.stat(savePath + "/" + file).mtime.getTime() > maxLifeTimeMS)
			{
				FileSystem.deleteFile(savePath + "/" + file);
			}
		}
	}
}
