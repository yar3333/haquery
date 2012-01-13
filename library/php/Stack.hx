package php;

class Stack 
{
	public static function nativeExceptionStack() : Array<Hash<Dynamic>>
	{
		var stack = php.Lib.toHaxeArray(untyped __php__("$GLOBALS['%nativeExceptionCallStack']"));
		for (i in 0...stack.length)
		{
			stack[i] = php.Lib.hashOfAssociativeArray(stack[i]);
			if (stack[i].exists('args'))
			{
				var args = php.Lib.toHaxeArray(stack[i].get('args'));
				if (args.length > 3) args[3] = php.Lib.toHaxeArray(args[3]);
				stack[i].set('args', args);
			}
		}
		return untyped stack;
	}
}
