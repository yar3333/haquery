package haquery;

import haxe.Stack;
using haquery.StringTools;

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
			if (Std.is(innerException, Exception))
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
		return message 
			+ "\n\tStack trace:" + Stack.toString(stackTrace).replace("\n", "\n\t\t") 
			+ (innerString != "" ? "INNER EXCEPTION: " + innerString : "");
	}
	
	public static function rethrow(exception:Dynamic) : Void
	{
		if (Std.is(exception, Exception))
		{
			throw exception;
		}
		else
		{
			var r = new Exception(Std.string(exception));
			r.stackTrace = haxe.Stack.exceptionStack();
			throw r;
		}
	}
	
	public static function trace(e:Dynamic) : Void
	{
		var text = "EXCEPTION: ";
		
		if (Std.is(e, Exception))
		{
			text += e.toString();
		}
		else
		{
			text += Std.string(e) + "\n\tStack trace:" + Stack.toString(Stack.exceptionStack()).replace("\n", "\n\t\t");
		}
		
		trace(text);
	}
}