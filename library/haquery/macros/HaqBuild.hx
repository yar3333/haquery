package haquery.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

class HaqBuild
{
	@:macro public static function preBuild()
	{
		if (!Context.defined("display"))
		{
			Context.onGenerate(function(types:Array<Type>)
			{
				for (type in types)
				{
					switch (type)
					{
						case Type.TInst(t, params):
							var clas = t.get();
							if (clas.pack.length > 0 && (clas.pack[0] == "components" || clas.pack[0] == "pages"))
							{
								if (HaqTools.isExtendsFrom(clas, "haquery.base.HaqComponent"))
								{
									HaqSharedGenerator.generate(clas);
								}
							}
						default:
					}
				}
			});
		}
		
		return macro null;
	}
}