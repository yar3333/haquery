package haquery.macros;

#if macro
import haxe.macro.Context;
#end

import haxe.macro.Expr;
import haxe.macro.Type;

class HaqBuild
{
	@:macro public static function postBuild()
	{
		/*
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
							if (isExtendsFrom(clas, "haquery.base.HaqComponent"))
							{
								setComponentClassEventHandlersArgTypes2(clas, clas.fields.get());
							}
						}
					default:
				}
			}
		});
		*/
		return Context.makeExpr(null, Context.currentPos());
	}
	
	#if macro
	
	static function isExtendsFrom(t:ClassType, parentClassPath:String) : Bool
	{
		while (t.superClass != null)
		{
			t = t.superClass.t.get();
			if (t.pack.join(".") + "." + t.name == parentClassPath)
			{
				return true;
			}
		}
		return false;
	}
	
	#end
}