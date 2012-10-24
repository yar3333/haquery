package haquery.server;

import haquery.common.HaqUploadError;

class HaqUploadedFile
{
    var tempFileName : String;
    
	public var name(default,null) : String;
    public var size(default, null) : Int;
    public var error(default,null) : HaqUploadError;
    
    public function new(tempFileName:String, name:String, size:Int, error:HaqUploadError) : Void
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
