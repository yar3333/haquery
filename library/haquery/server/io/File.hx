package haquery.server.io;

#if php

typedef File = php.io.File;

#elseif neko

typedef HaxeFile = neko.io.File;

class File 
{
	public static inline function getContent( path : String ) { return HaxeFile.getContent(path); }
	public static inline function getBytes( path : String ) { return HaxeFile.getBytes(path); }
	public static inline function read( path : String, binary : Bool = true ) { return HaxeFile.read(path, binary); }
	public static inline function write( path : String, binary : Bool = true ) { return HaxeFile.write(path, binary); }
	public static inline function append( path : String, binary : Bool = true ) { return HaxeFile.append(path, binary); }
	public static inline function copy( src : String, dst : String ) { return HaxeFile.copy(src, dst); }
	public static inline function stdin() { return HaxeFile.stdin(); }
	public static inline function stdout() { return HaxeFile.stdout(); }
	public static inline function stderr() { return HaxeFile.stderr(); }
	public static inline function getChar( echo : Bool ) : Int { return HaxeFile.getChar(echo); }
	
	public static function putContent( path : String, text : String )
	{
		var fout = write(path);
		fout.writeString(text);
		fout.close();
	}
} 

#end