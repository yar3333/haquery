package haquery.client;

#if !macro

import haquery.common.HaqComponentTools;
import haquery.common.Generated;
import stdlib.Exception;
import js.JQuery;

using stdlib.StringTools;

#end

@:autoBuild(haquery.macro.HaqComponentTools.build()) @:keepSub class HaqComponent extends haquery.base.HaqComponent
{
#if !macro

	var isDynamic : Bool;
	
	public function construct(fullTag:String, parent:HaqComponent, id:String, isDynamic:Bool, dynamicParams:Dynamic) : Void
	{
		super.commonConstruct(fullTag, parent, id);
		
		this.page = parent != null ? parent.page : cast this;
		this.isDynamic = isDynamic;
		
		connectElemEventHandlers();
        createEvents();
		createChildComponents();
	}
	
	public function createChildComponents() : Void
	{
		for (component in Lib.manager.getChildComponents(this))
		{
			Lib.manager.createComponent(this, component.fullTag, component.id, isDynamic);
		}
	}
	
	public function q(?arg:Dynamic, ?base:Dynamic) : HaqQuery
	{
		var cssGlobalizer = new HaqCssGlobalizer(fullTag);
		
		if (arg != null && arg != "" && Std.is(arg, String))
		{
			arg = cssGlobalizer.selector(arg.replace('#', '#' + prefixID));
		}
		
		return cssGlobalizer.fixJq(new HaqQuery(arg, base));
	}
    
    function connectElemEventHandlers() : Void
    {
		HaqElemEventManager.connect(this, this);
    }
	
	/**
	 * Call server method, marked as @shared.
	 */
	public function callSharedServerMethod(method:String, params:Array<Dynamic>, success:Dynamic->Void, fail:Exception->Void) : Void
	{
		page.ajax.callSharedMethod(fullID, method, params, success);
	}
	
	/**
	 * Call client method, marked with meta.
	 */
	public function callClientMethod(method:String, params:Array<Dynamic>, ?meta:String) : Dynamic
	{
		return HaqComponentTools.callMethod(this, method, params, meta);
	}

#end
	
	@:macro public function template(ethis:haxe.macro.Expr)
	{
		return haquery.macro.HaqComponentTools.template(ethis);
	}
	
	@:macro public function server(ethis:haxe.macro.Expr)
	{
		return haquery.macro.HaqComponentTools.shared(ethis);
	}
}
