package haquery.server.cache;

import haquery.server.FileSystem;
import haquery.server.io.File;
import haxe.Serializer;
import haxe.Unserializer;
using haquery.StringTools;

class HaqCacheDriver_filesystem implements HaqCacheDriver
{
	var folder : String;
	
	public function new(folder:String) : Void
	{
		folder = folder.replace("\\", "/").rtrim("/");
		
		if (!FileSystem.exists(folder))
		{
			FileSystem.createDirectory(folder);
		}
		
		this.folder = folder + "/";
	}
	
	public function get(key:String) : Dynamic
	{
		var filePath = getFilePath(key);
		if (FileSystem.exists(filePath))
		{
			#if neko
			return neko.Lib.localUnserialize(neko.Lib.bytesReference(File.getContent(filePath)));
			#else
			return Unserializer.run(File.getContent(filePath));
			#end
		}
		return null;
	}
	
	public function set(key:String, obj:Dynamic) : Void
	{
		#if neko
		File.putContent(getFilePath(key), neko.Lib.stringReference(neko.Lib.serialize(obj)));
		#else
		File.putContent(getFilePath(key), Serializer.run(obj));
		#end
	}
	
	public function remove(key:String) : Void
	{
		var filePath = getFilePath(key);
		if (FileSystem.exists(filePath))
		{
			FileSystem.deleteFile(filePath);
		}
	}
	
	public function removeAll() : Void
	{
		var folderWoEndSlash = folder.substr(0, folder.length - 1);
		
		for (file in FileSystem.readDirectory(folderWoEndSlash))
		{
			FileSystem.deleteFile(folder + file);
		}
	}
	
	public function dispose() : Void
	{
		folder = null;
	}
	
	public function getFilePath(key:String)
	{
		return folder + key;
	}
}