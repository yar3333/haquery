package haquery.server.db;

import haquery.Exception;

class HaqDbException extends Exception
{
	public var code(default, null) : Int;
	
	public function new(code:Int, message:String) 
	{
		super(message);
		this.code = code;
	}
}