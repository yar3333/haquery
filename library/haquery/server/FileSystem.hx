package haquery.server;

class FileSystem 
{
	/**
	*	Tells if the given file or directory exists.
	*/
	public static inline function exists(path:String) : Bool { return sys.FileSystem.exists(path); }

	/**
		Rename the corresponding file or directory, allow to move it accross directories as well.
	*/
	public static inline function rename(path:String, newpath:String) : Void { sys.FileSystem.rename(path, newpath); }

	/**
		Returns informations for the given file/directory.
	*/
	public static inline function stat(path:String) : sys.FileStat { return sys.FileSystem.stat(path); }

	/**
		Returns the full path for the given path which is relative to the current working directory.
	*/
	public static inline function fullPath(relpath:String) : String { return sys.FileSystem.fullPath(relpath); }

	/**
		Tells if the given path is a directory. Throw an exception if it does not exists or is not accesible.
	*/
	public static inline function isDirectory(path:String) : Bool { return sys.FileSystem.isDirectory(path); }

	/**
		Create the given directory. Not recursive : the parent directory must exists.
	*/
	public static function createDirectory(path:String) : Void
	{
		if (path != null && path != "" && !exists(path))
		{
			path = StringTools.replace(path, '\\', '/');
			
			if (path.substr(-1) == "/")
			{
				path = path.substr(0, path.length - 1);
			}
			
			var dirs : Array<String> = path.split('/');
			for (i in 0...dirs.length)
			{
				var dir = dirs.slice(0, i + 1).join('/');
				if (dir != "" && dir.substr(-1) != ':')
				{
					if (!exists(dir))
					{
						sys.FileSystem.createDirectory(dir);
					}
				}
			}
		}
	}

	/**
		Delete a given file.
	*/
	public static inline function deleteFile(path:String) : Void { sys.FileSystem.deleteFile(path); }
	/**
		Delete a given directory.
	*/
	public static inline function deleteDirectory(path:String) : Void { sys.FileSystem.deleteDirectory(path); }

	/**
		Read all the files/directories stored into the given directory.
	*/
	public static inline function readDirectory(path:String) : Array<String> { return sys.FileSystem.readDirectory(path); }
}