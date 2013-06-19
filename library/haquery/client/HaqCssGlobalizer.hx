package haquery.client;

#if client

class HaqCssGlobalizer extends haquery.base.HaqCssGlobalizer
{
	public function fixJq(jq:js.JQuery) : js.JQuery
	{
		var self = this;
		
		untyped 
		{
			jq.addClass		= function(arg) return self.fixJq(jQuery.fn.addClass.call(jq, self.className(arg)));
			jq.removeClass	= function(arg) return self.fixJq(jQuery.fn.removeClass.call(jq, self.className(arg)));
			jq.hasClass		= function(arg) return            jQuery.fn.hasClass.call(jq, self.className(arg));
			jq.find			= function(arg) return self.fixJq(jQuery.fn.find.call(jq, self.selector(arg)));
			jq.filter		= function(arg) return self.fixJq(jQuery.fn.filter.call(jq, self.selector(arg)));
			jq.has			= function(arg) return            jQuery.fn.has.call(jq, self.selector(arg));
			jq.is			= function(arg) return            jQuery.fn.is.call(jq, self.selector(arg));
			jq.not			= function(arg) return self.fixJq(jQuery.fn.not.call(jq, self.selector(arg)));
			jq.parent		= function()    return self.fixJq(jQuery.fn.parent.call(jq));
		}
		
		return jq;
	}
}

#end