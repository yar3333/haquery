package haquery.macro;

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

class HaqBuild
{
	macro public static function startup()
	{
		if (Context.defined("display"))
		{
			var displayPos = "";// Compiler.getDisplayPos();
			if (~/\bserver\b/.match(displayPos))
			{
				Compiler.define("server");
			}
			else
			if (~/\bclient\b/.match(displayPos))
			{
				Compiler.define("client");
			}
			else
			{
				Compiler.define("server");
				Compiler.define("client");
			}
		}
		else
		{
			Context.onGenerate(function(types:Array<Type>)
			{
				for (type in types)
				{
					switch (type)
					{
						case Type.TInst(t, params):
								HaqSharedGenerator.generate(t.get());
						default:
					}
				}
			});
		}
		return macro null;
	}
}