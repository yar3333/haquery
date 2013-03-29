package haquery.client;

#if !macro

import haquery.common.HaqComponentTools;
import models.client.Page;
import stdlib.Exception;
import js.JQuery;
using stdlib.StringTools;

#end

@:autoBuild(haquery.macro.HaqComponentTools.build()) @:keepSub class HaqComponent extends haquery.base.HaqComponent
{
#if !macro

	public var page(default,null) : Page;
	
	var isDynamic : Bool;
	
	public function construct(manager:HaqTemplateManager, fullTag:String, parent:HaqComponent, id:String, isDynamic:Bool, dynamicParams:Dynamic) : Void
	{
		super.commonConstruct(manager, fullTag, parent, id);
		
		this.page = parent != null ? parent.page : cast(this, Page);
		this.isDynamic = isDynamic;
		
		connectElemEventHandlers();
        createEvents();
		createChildComponents();
	}
	
	public function createChildComponents() : Void
	{
		for (component in manager.getChildComponents(this))
		{
			manager.createComponent(this, component.fullTag, component.id, isDynamic);
		}
	}
	
	public function q(?arg:Dynamic, ?base:Dynamic) : HaqQuery
	{
		var cssGlobalizer = new HaqCssGlobalizer(fullTag);
		
		if (arg != null && arg != "" && Type.getClass(arg) == String)
		{
			var selector : String = arg;
			if (selector != null && prefixID != '')
			{
				selector = selector.replace('#', '#' + prefixID);
			}
			arg = cssGlobalizer.selector(selector);
		}
		
		var jq = new HaqQuery(arg, base);
		
		untyped 
		{
			jq.haquery_addClass = jq.addClass;
			jq.addClass = function(name) { return jq.haquery_addClass(cssGlobalizer.className(name)); };
			
			jq.haquery_removeClass = jq.removeClass;
			jq.removeClass = function(name) { return jq.haquery_removeClass(cssGlobalizer.className(name)); };

			jq.haquery_hasClass = jq.hasClass;
			jq.hasClass = function(name) { return jq.haquery_hasClass(cssGlobalizer.className(name)); };
			
			jq.haquery_find = jq.find;
			jq.find = function(arg) { return jq.haquery_find(__js__("typeof arg")=='string' ? cssGlobalizer.selector(arg) : arg); };
			
			jq.haquery_filter = jq.filter;
			jq.filter = function(arg) { return jq.haquery_filter(__js__("typeof arg")=='string' ? cssGlobalizer.selector(arg) : arg); };
			
			jq.haquery_has = jq.has;
			jq.has = function(arg) { return jq.haquery_has(__js__("typeof arg")=='string' ? cssGlobalizer.selector(arg) : arg); };
			
			jq.haquery_is = jq.is;
			jq.is = function(arg) { return jq.haquery_is(__js__("typeof arg")=='string' ? cssGlobalizer.selector(arg) : arg); };
			
			jq.haquery_not = jq.not;
			jq.not = function(arg) { return jq.haquery_not(__js__("typeof arg")=='string' ? cssGlobalizer.selector(arg) : arg); };
			
			jq.haquery_parent = jq.parent;
			jq.parent = function(arg) { return jq.haquery_parent(__js__("typeof arg")=='string' ? cssGlobalizer.selector(arg) : arg); };
		}
		
		return jq;
	}
    
    function connectElemEventHandlers() : Void
    {
		HaqElemEventManager.connect(this, this, manager);
    }
	
	/**
	 * Call server method, marked as @shared.
	 */
	public function callSharedServerMethod(method:String, params:Array<Dynamic>, success:Dynamic->Void, fail:Exception->Void) : Void
	{
		Lib.ajax.callSharedMethod(fullID, method, params, success);
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
	
	@:macro public function server(ethis:haxe.macro.Expr, ?pageKey:haxe.macro.Expr.ExprOf<String>)
	{
		return haquery.macro.HaqTools.isNull(pageKey) ? haquery.macro.HaqComponentTools.shared(ethis) : haquery.macro.HaqComponentTools.anotherServer(ethis, pageKey);
	}
	
	@:macro public function client(ethis:haxe.macro.Expr, pageKey:haxe.macro.Expr.ExprOf<String>)
	{
		return haquery.macro.HaqComponentTools.anotherClient(ethis, pageKey);
	}
}
