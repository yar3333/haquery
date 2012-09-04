package haquery.macros;

class HaqComponent 
{
	function new() : Void
	{
		var templateClass = haquery.base.HaqComponentTools.getTemplateClass(Type.getClass(this));
		if (templateClass != null)
		{
			Reflect.setField(this, "_template", Type.createInstance(templateClass, [ this ]));
		}
	}
	
	@:macro public function template(ethis:haxe.macro.Expr)
	{
		var pos = haxe.macro.Context.currentPos();
		
		switch (haxe.macro.Context.typeof(ethis))
		{
			case haxe.macro.Type.TInst(t, params):
				var clas = t.get();
				if (clas.pack.length > 0 && (clas.pack[0] == "components" || clas.pack[0] == "pages") && (clas.name == "Server" || clas.name == "Client"))
				{
					var typePath = { sub:null, params:[], pack:clas.pack, name:"Template" + clas.name };
					return { expr:haxe.macro.Expr.ExprDef.ENew(typePath, [ ethis ]), pos:pos };
				}
			default:
		}
		
		return haxe.macro.Context.makeExpr(null, pos);
	}
}