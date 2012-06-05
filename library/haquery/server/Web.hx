package haquery.server;

import haxe.io.Bytes;
import haquery.server.FileSystem;
import haquery.server.io.File;
import microtime.Date;

#if php
private typedef HaxeWeb = php.Web;
#elseif neko
private typedef HaxeWeb = neko.Web;
#end

enum UploadError
{
	/**
	 * Value: 0; There is no error, the file uploaded with success.
	 */
	OK;

	/**
	 * Value: 1; The uploaded file exceeds the upload_max_filesize directive in php.ini.
	 */
	INI_SIZE;

	/**
	 * Value: 2; The uploaded file exceeds the MAX_FILE_SIZE directive that was specified in the HTML form.
	 */
	FORM_SIZE;

	/**
	 * Value: 3; The uploaded file was only partially uploaded.
	 */
	PARTIAL;

	/**
	 * Value: 4; No file was uploaded.
	 */
	NO_FILE;

	/**
	 * Value: 6; Missing a temporary folder. Introduced in PHP 4.3.10 and PHP 5.0.3.
	 */
	NO_TMP_DIR;

	/**
	 * Value: 7; Failed to write file to disk. Introduced in PHP 5.1.0.
	 */
	CANT_WRITE;

	/**
	 * Value: 8; A PHP extension stopped the file upload. PHP does not provide a way to ascertain which extension caused the file upload to stop; examining the list of loaded extensions with phpinfo() may help. Introduced in PHP 5.2.0.
	 */
	EXTENSION;
}

class UploadedFile
{
    var tempFileName : String;
    
	public var name(default,null) : String;
    public var size(default, null) : Int;
    public var error(default,null) : UploadError;
    
    public function new(tempFileName:String, name:String, size:Int, error:UploadError) : Void
    {
        this.tempFileName = tempFileName;
        this.name = name;
        this.size = size;
        this.error = error;
    }
    
    public function move(destFilePath:String) : Void
    {
        #if php
		untyped __call__("move_uploaded_file", tempFileName, destFilePath);
		#elseif neko
		FileSystem.rename(tempFileName, destFilePath);
		#end
    }
}

/**
	This class is used for accessing the local Web server and the current
	client request and informations.
**/
class Web {

	/**
		Returns the GET and POST parameters.
	**/
	public static inline function getParams() : Hash<String> { return HaxeWeb.getParams(); }

	/**
		Returns an Array of Strings built using GET / POST values.
		If you have in your URL the parameters [a[]=foo;a[]=hello;a[5]=bar;a[3]=baz] then
		[HaxeWeb.getParamValues("a")] will return [["foo","hello",null,"baz",null,"bar"]]
	**/
	public static inline function getParamValues( param : String ) : Array<String> { return HaxeWeb.getParamValues(param); }

	/**
		Returns the local server host name
	**/
	public static inline function getHostName() : String { return HaxeWeb.getHostName(); }

	/**
		Surprisingly returns the client IP address.
	**/
	public static inline function getClientIP() : String
	{
		var realIP = getClientHeader("X-Real-IP");
		return realIP != null && realIP != "" ? realIP : HaxeWeb.getClientIP();
	}

	/**
		Returns the original request URL (before any server internal redirections)
	**/
	public static inline function getURI() : String { return HaxeWeb.getURI(); }

	/**
		Tell the client to redirect to the given url ("Location" header)
	**/
	public static inline function redirect( url : String ) : Void { haquery.server.Lib.redirect(url); }

	/**
		Set an output header value. If some data have been printed, the headers have
		already been sent so this will raise an exception.
	**/
	public static inline function setHeader( h : String, v : String ) : Void { HaxeWeb.setHeader(h,v); }

	/**
		Set the HTTP return code. Same remark as setHeader.
		See status code explanation here: http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
	**/
	public static inline function setReturnCode( r : Int ) : Void { HaxeWeb.setReturnCode(r); }

	/**
		Retrieve a client header value sent with the request.
	**/
	public static inline function getClientHeader( k : String ) : String { return HaxeWeb.getClientHeader(k); }
	
	/**
		Retrieve all the client headers.
	**/
	public static inline function getClientHeaders() : List<{header : String, value : String}> { return HaxeWeb.getClientHeaders(); }

	/**
		Returns all the GET parameters String
	**/
	public static inline function getParamsString() : String { return HaxeWeb.getParamsString(); }

	/**
		Returns all the POST data. POST Data is always parsed as
		being application/x-www-form-urlencoded and is stored into
		the getParams hashtable. POST Data is maximimized to 256K
		unless the content type is multipart/form-data. In that
		case, you will have to use [getMultipart] or [parseMultipart]
		methods.
	**/
	public static inline function getPostData() : String { return HaxeWeb.getPostData(); }

	/**
		Returns an object with the authorization sent by the client (Basic scheme only).
	**/
	public static inline function getAuthorization() : { user : String, pass : String } { return HaxeWeb.getAuthorization(); }

	/**
		Get the current script directory in the local filesystem.
	**/
	public static inline function getCwd() : String { return HaxeWeb.getCwd(); }

	/**
		Get the multipart parameters as an hashtable. The data
		cannot exceed the maximum size specified.
	**/
	public static inline function getMultipart( maxSize : Int ) : Hash<String> { return HaxeWeb.getMultipart(maxSize); }

	/**
		Parse the multipart data. Call [onPart] when a new part is found
		with the part name and the filename if present
		and [onData] when some part data is readed. You can this way
		directly save the data on hard drive in the case of a file upload.
	**/
	public static inline function parseMultipart( onPart : String -> String -> Void, onData : Bytes -> Int -> Int -> Void ) : Void { HaxeWeb.parseMultipart(onPart, onData); }

	/**
		Flush the data sent to the client. By default on Apache, outgoing data is buffered so
		this can be useful for displaying some long operation progress.
	**/
	public static inline function flush() : Void { HaxeWeb.flush(); }

	/**
		Get the HTTP method used by the client.
	**/
	public static inline function getMethod() : String { return HaxeWeb.getMethod(); }

	public static var isModNeko(isModNeko_getter, null) : Bool; 
    static inline function isModNeko_getter() : Bool  { return HaxeWeb.isModNeko; }

	public static function getHttpHost() : String 
	{
        #if php
		return untyped __var__("_SERVER", "HTTP_HOST"); 
		#else
		return getClientHeader("Host");
		#end
    }
	
	public static function getUploadedFiles(maxUploadDataSize:Int) : Hash<UploadedFile>
	{
        #if php
		
		var files = new Hash<UploadedFile>();
		var nativeFiles : Hash<php.NativeArray> = Lib.hashOfAssociativeArray(untyped __var__("_FILES"));
		for (id in nativeFiles.keys())
		{
			var file : php.NativeArray = nativeFiles.get(id);
            files.set(id, new UploadedFile(
                 file[untyped "tmp_name"]
                ,file[untyped "name"]
                ,file[untyped "size"]
                ,Type.createEnumIndex(UploadError, file[untyped "error"])
            ));
        }
		return files;
		
		#elseif neko
		
		var files = new Hash<UploadedFile>();
		
		var lastPartName : String = null;
		var lastFileName : String = null;
		var lastTempFileName : String = null;
		
		var error : UploadError = null;
		
		Web.parseMultipart(
			function(partName:String, fileName:String)
			{
				if (partName != lastPartName)
				{
					if (lastPartName != null)
					{
						files.set(
							lastPartName
						   ,new UploadedFile(lastTempFileName, lastFileName, FileSystem.stat(lastTempFileName).size, error)
						);
					}
					
					lastPartName = partName;
					lastFileName = fileName;
					lastTempFileName = getTempUploadedFilePath();
					error = UploadError.OK;
					
				}
			}
		   ,function(data:Bytes, offset:Int, length:Int)
			{
				maxUploadDataSize -= length;
				if (maxUploadDataSize >= 0)
				{
					var h = File.append(lastTempFileName);
					h.seek(offset, sys.io.FileSeek.SeekBegin);
					h.writeBytes(data, 0, length);
					h.close();
				}
				else
				{
					error = UploadError.INI_SIZE;
					if (FileSystem.exists(lastTempFileName))
					{
						FileSystem.deleteFile(lastTempFileName);
					}
				}
			}
		);
		
		if (lastPartName != null)
		{
			files.set(
				lastPartName
			   ,new UploadedFile(lastTempFileName, lastFileName, FileSystem.stat(lastTempFileName).size, error)
			);
		}
		
        return files;
		
		#end
	}
	
	static function getTempUploadedFilePath()
	{
		var s = Std.string(Date.now().getTime());
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
}
