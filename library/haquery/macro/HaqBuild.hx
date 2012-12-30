package haquery.macro;

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

class HaqBuild
{
	@:macro public static function startup()
	{
		if (Context.defined("display"))
		{
			//if (Compiler.getDisplayPos().indexOf("client"))
			Compiler.define("server");
			Compiler.define("client");
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
								HaqSharedAndAnotherGenerator.generate(t.get());
						default:
					}
				}
			});
		}
		return macro null;
	}
}