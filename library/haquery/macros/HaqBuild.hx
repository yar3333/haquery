package haquery.macros;

import haxe.macro.Compiler;
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
									HaqSharedAndAnotherGenerator.generate(clas);
								}
							}
						default:
					}
				}
			});
		}
		
		return macro null;
	}
	
	@:macro public static function excludeOtherTarget()
	{
		if (Context.defined("display") && !Context.defined("js"))
		{
			Compiler.exclude("components.geography.buyer", true);
			//Compiler.define("client");
			//Compiler.define("js");
			
			/*var c = HaqTools.getClassType("components.geography.buyer.Client");
			HaqTools.log("EXCLUDE = " + c.name);
			c.exclude();
			Context.*/
		}
		
		/*
		HaqTools.log("BUILD = " + componentClass.name);
		var fileAndPos = Compiler.getDisplayPos();
		if (fileAndPos != null)
		{
			HaqTools.log("FILE = " + fileAndPos.file);
			if (new EReg("(?:^|[\\/])server[\\/]|(?:^|[\\/]Server[.]hx$)", "i").match(fileAndPos.file))
			{
				if (componentClass.name == "Client")
				{
					componentClass.exclude();
					return [];
				}
			}
		}*/

		
		return macro null;
	}
}