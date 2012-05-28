package php;

class Stack 
{
	public static function nativeExceptionStack() : Array<Hash<Dynamic>>
	{
		if (untyped __php__("isset($GLOBALS['%nativeExceptionCallStack'])"))
		{
			var stack = Lib.toHaxeArray(untyped __php__("$GLOBALS['%nativeExceptionCallStack']"));
			for (i in 0...stack.length)
			{
				stack[i] = Lib.hashOfAssociativeArray(stack[i]);
				if (stack[i].exists('args'))
				{
					var args = Lib.toHaxeArray(stack[i].get('args'));
					if (args.length > 3) args[3] = Lib.toHaxeArray(args[3]);
					stack[i].set('args', args);
				}
			}
			return untyped stack;
		}
		else
		{
			return null;
		}
	}
}
