package haquery.server;

import haquery.common.HaqUploadError;

class HaqUploadedFile
{
    public var path(default,null) : String;
	public var name(default,null) : String;
    public var size(default, null) : Int;
    public var error(default,null) : HaqUploadError;
    
    public function new(path:String, name:String, size:Int, error:HaqUploadError) : Void
    {
        this.path = path;
        this.name = name;
        this.size = size;
        this.error = error;
    }
}
