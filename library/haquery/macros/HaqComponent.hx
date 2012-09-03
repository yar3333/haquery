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
		var localClass = haxe.macro.Context.getLocalClass().get();
		if (localClass.pack.length > 0 && (localClass.pack[0] == "components" || localClass.pack[0] == "pages") && (localClass.name == "Server" || localClass.name == "Client"))
		{
			var typePath = { sub:null, params:[], pack:localClass.pack, name:"Template" + localClass.name };
			var templateExpr = { expr:haxe.macro.Expr.ExprDef.EField(ethis, "_template"), pos:pos };
			var untypedTemplateExpr = { expr:haxe.macro.Expr.ExprDef.EUntyped(templateExpr), pos:pos };
			return { expr:haxe.macro.Expr.ExprDef.ECast(untypedTemplateExpr, haxe.macro.Expr.ComplexType.TPath(typePath)), pos:pos };
		}
		return haxe.macro.Context.makeExpr(null, pos);
	}
}