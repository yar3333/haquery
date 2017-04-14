package haquery.client;

import js.Browser.window;

class HaqCssGlobalizer extends haquery.base.HaqCssGlobalizer
{
	public function fixJq(jq:js.JQuery) : js.JQuery
	{
		var self = this;
		
		(cast jq).addClass		= function(arg)		return self.fixJq((cast window).jQuery.fn.addClass.call(jq, self.className(arg)));
		(cast jq).removeClass	= function(arg)		return self.fixJq((cast window).jQuery.fn.removeClass.call(jq, self.className(arg)));
		(cast jq).toggleClass	= function(arg, b)	return self.fixJq((cast window).jQuery.fn.toggleClass.call(jq, self.className(arg), b));
		(cast jq).hasClass		= function(arg)		return            (cast window).jQuery.fn.hasClass.call(jq, self.className(arg));
		(cast jq).find			= function(arg)		return self.fixJq((cast window).jQuery.fn.find.call(jq, self.selector(arg)));
		(cast jq).filter		= function(arg)		return self.fixJq((cast window).jQuery.fn.filter.call(jq, self.selector(arg)));
		(cast jq).has			= function(arg)		return            (cast window).jQuery.fn.has.call(jq, self.selector(arg));
		(cast jq).is			= function(arg)		return            (cast window).jQuery.fn.is.call(jq, self.selector(arg));
		(cast jq).not			= function(arg)		return self.fixJq((cast window).jQuery.fn.not.call(jq, self.selector(arg)));
		(cast jq).parent		= function()		return self.fixJq((cast window).jQuery.fn.parent.call(jq));
		
		return jq;
	}
}
