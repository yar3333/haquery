package haquery;

import haxe.Stack;

class Exception 
{
	public var message(default, null) : String;
	public var stackTrace(default, null) : Array<StackItem>;
	public var innerException(default, null) : Exception;
	public var baseException(baseException_getter, null) : Exception;

	public function new(?message:String, ?innerException:Dynamic)
	{
		this.message = message == null ? "" : message;
		
		if (innerException != null)
		{
			if (isExceptionInstance(innerException))
			{
				this.innerException = innerException;
			}
			else
			{
				this.innerException = new Exception(Std.string(innerException), null);
				this.innerException.stackTrace = Stack.exceptionStack();
			}
		}
		
		stackTrace = Stack.callStack();
		stackTrace.shift();
		
		var c : Class<Dynamic> = Type.getClass(this);
		while (c != Exception) 
		{ 
			stackTrace.shift();
			c = Type.getSuperClass(c);
		}
	}

	function baseException_getter() 
	{
		var inner = this;
		while (inner.innerException != null)
		{
			inner = inner.innerException;
		}
		return inner;
	}
	
	public function toString() : String
	{
		var innerString = innerException != null ? innerException.toString() : "";
		return "EXCEPTION: " + message + Stack.toString(stackTrace) + (innerString != "" ? "INNER " + innerString : "");
	}
	
	static function isExceptionInstance(obj:Dynamic) : Bool
	{
		var c : Class<Dynamic> = Type.getClass(obj);
		
		do {
			if (c == Exception) return true;
			c = Type.getSuperClass(c);
		} while (c != null);
		
		return false;
	}
	
	public static function rethrow(exception:Dynamic) : Void
	{
		if (isExceptionInstance(exception))
		{
			throw exception;
		}
		else
		{
			var r = new Exception(Std.string(exception), null);
			r.stackTrace = haxe.Stack.exceptionStack();
			throw r;
		}
	}
}