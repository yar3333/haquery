package haquery.server;

import haxe.io.Bytes;

#if php
private typedef HaxeWeb = php.Web;
#elseif neko
private typedef HaxeWeb = neko.Web;
#elseif cpp
private typedef HaxeWeb = cpp.Web;
#end

class UploadedFile
{
    public var name(default,null) : String;
    public var type(default,null) : String;
    public var tmp_name(default,null) : String;
    public var error(default,null) : UploadError;
    public var size(default, null) : Int;
    
    public function new(name:String, type:String, tmp_name:String, error:UploadError, size:Int) : Void
    {
        this.name = name;
        this.type = type;
        this.tmp_name = tmp_name;
        this.error = error;
        this.size = size;
    }
    
    public function move(destFilePath:String) : Void
    {
        untyped __call__('move_uploaded_file', tmp_name, destFilePath);
    }
}

enum UploadError
{
	/**
	 * Value: 0; There is no error, the file uploaded with success.
	 */
	UPLOAD_ERR_OK;

	/**
	 * Value: 1; The uploaded file exceeds the upload_max_filesize directive in php.ini.
	 */
	UPLOAD_ERR_INI_SIZE;

	/**
	 * Value: 2; The uploaded file exceeds the MAX_FILE_SIZE directive that was specified in the HTML form.
	 */
	UPLOAD_ERR_FORM_SIZE;

	/**
	 * Value: 3; The uploaded file was only partially uploaded.
	 */
	UPLOAD_ERR_PARTIAL;

	/**
	 * Value: 4; No file was uploaded.
	 */
	UPLOAD_ERR_NO_FILE;

	/**
	 * Value: 6; Missing a temporary folder. Introduced in PHP 4.3.10 and PHP 5.0.3.
	 */
	UPLOAD_ERR_NO_TMP_DIR;

	/**
	 * Value: 7; Failed to write file to disk. Introduced in PHP 5.1.0.
	 */
	UPLOAD_ERR_CANT_WRITE;

	/**
	 * Value: 8; A PHP extension stopped the file upload. PHP does not provide a way to ascertain which extension caused the file upload to stop; examining the list of loaded extensions with phpinfo() may help. Introduced in PHP 5.2.0.
	 */
	UPLOAD_ERR_EXTENSION;
}

/**
	This class is used for accessing the local Web server and the current
	client request and informations.
**/
class Web {

	/**
		Returns the GET and POST parameters.
	**/
	public static inline function getParams() { return HaxeWeb.getParams(); }

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
	public static inline function getClientIP() : String { return HaxeWeb.getClientIP(); }

	/**
		Returns the original request URL (before any server internal redirections)
	**/
	public static inline function getURI() : String { return HaxeWeb.getURI(); }

	/**
		Tell the client to redirect to the given url ("Location" header)
	**/
	public static inline function redirect( url : String ) { return haquery.server.Lib.redirect(url); }

	/**
		Set an output header value. If some data have been printed, the headers have
		already been sent so this will raise an exception.
	**/
	public static inline function setHeader( h : String, v : String ) { return HaxeWeb.setHeader(h,v); }

	/**
		Set the HTTP return code. Same remark as setHeader.
		See status code explanation here: http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
	**/
	public static inline function setReturnCode( r : Int ) { return HaxeWeb.setReturnCode(r); }

	/**
		Retrieve a client header value sent with the request.
	**/
	public static inline function getClientHeader( k : String ) : String { return HaxeWeb.getClientHeader(k); }
	
	/**
		Retrieve all the client headers.
	**/
	public static inline function getClientHeaders() { return HaxeWeb.getClientHeaders(); }

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
	public static inline function getPostData() { return HaxeWeb.getPostData(); }

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
	public static inline function parseMultipart( onPart : String -> String -> Void, onData : Bytes -> Int -> Int -> Void ) : Void { return HaxeWeb.parseMultipart(onPart, onData); }

	/**
		Flush the data sent to the client. By default on Apache, outgoing data is buffered so
		this can be useful for displaying some long operation progress.
	**/
	public static inline function flush() : Void { return HaxeWeb.flush(); }

	/**
		Get the HTTP method used by the client.
	**/
	public static inline function getMethod() : String { return HaxeWeb.getMethod(); }

	public static var isModNeko(isModNeko_getter, null) : Bool; 
    static inline function isModNeko_getter() : Bool  { return HaxeWeb.isModNeko; }

	#if php
	public static function getHttpHost() : String {
        return untyped __php__("$_SERVER['HTTP_HOST']"); 
    }

	public static function getFiles() : Hash<UploadedFile> 
    {
        var files : Hash<php.NativeArray> = Lib.hashOfAssociativeArray(untyped __var__("_FILES"));
        var r = new Hash<UploadedFile>();
        for (id in files.keys())
        {
            var file : php.NativeArray = files.get(id);
            r.set(id, new UploadedFile(
                 file[untyped "name"]
                ,file[untyped "type"]
                ,file[untyped "tmp_name"]
                ,Type.createEnumIndex(UploadError, file[untyped "error"])
                ,file[untyped "size"]
            ));
        }
        return r;
    }
	#end
}
