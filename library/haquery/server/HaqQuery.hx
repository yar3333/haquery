package haquery.server;

import stdlib.Std;
import htmlparser.HtmlNodeElement;
import haquery.base.HaqCssGlobalizer;
using stdlib.StringTools;

private typedef Page =
{
	var isPostback(default, null) : Bool;
	var params(default, null) : HaqParams;
	function addAjaxResponse(js:String) : Void;
};

/**
 * Like $ in jQuery.
 */
class HaqQuery
{
    var page(default, null) : Page;
    var prefixID(default, null) : String;
   
	var cssGlobalizer(default, null) : HaqCssGlobalizer;
	
	/**
     * Original CSS-selector.
     */
    public var query(default, null) : String;
    
    /**
     * Selected XML DOM nodes (elements).
     */
    public var nodes(default, null) : Array<HtmlNodeElement>;
    
    function jQueryCall(method)
    {
        page.addAjaxResponse("$('" + query.replace('#', '#' + prefixID) + "')." + method + ";");
    }
    
	public function new(page:Page, prefixID:String, cssGlobalizer:HaqCssGlobalizer, query:String, nodes:Array<HtmlNodeElement>)
    {
        this.page = page;
		this.prefixID = prefixID;
		
		this.cssGlobalizer = cssGlobalizer;
        this.query = query;
        this.nodes = nodes != null ? nodes : [];
    }
	
    public function toString()
    {
        return nodes.join('');
    }

    public function size() : Int { return nodes.length; }

    public function get(index:Int) : HtmlNodeElement
    {
        return nodes[index];
    }

    /**
     * Get or set attribute value.
     */
    public function attr(name:String, value:String=null) : Dynamic
    {
        if (value == null)
		{
			return nodes.length > 0 ? nodes[0].getAttribute(name) : null;
		}
        
		for (node in nodes)
		{
			node.setAttribute(name, value);
		}
        
		if (page.isPostback)
		{
			jQueryCall('attr("' + name + '","' + value + '")');
		}
        
		return this;
    }

    public function removeAttr(name:String) : HaqQuery
    {
        for (node in nodes)
		{
			node.removeAttribute(name);
		}
        
		if (page.isPostback)
		{
			jQueryCall("removeAttr('" + name + "')");
		}
        
		return this;
    }

    public function addClass(cssClass:String) : HaqQuery
    {
        cssClass = cssGlobalizer.className(cssClass);
		
		var classes = ~/\s+/.split(cssClass);
        for (node in nodes)
        {
            var s = node.hasAttribute('class') ? node.getAttribute('class') : '';
            for (c in classes)
            {
                if (!(new EReg('(^|\\s)' + c + '(\\s|$)', '')).match(s))
				{
					s += " " + c;
				}
            }
            node.setAttribute('class', s.ltrim());
        }

        if (page.isPostback)
		{
			jQueryCall('addClass("' + cssClass + '")');
		}

        return this;
    }

    public function toggleClass(cssClass:String, on:Bool) : HaqQuery
    {
        if (on) addClass(cssClass);
		else    removeClass(cssClass);
        return this;
    }
    
	public function hasClass(cssClass:String) : Bool
    {
        cssClass = cssGlobalizer.className(cssClass);
        
		var classes = ~/\s+/.split(cssClass);
        for (node in nodes)
        {
            var s = node.hasAttribute('class') ? node.getAttribute('class') : '';
            var inAll = true;
            for (c in classes)
            {
                if (!(new EReg('(^|\\s)' + c + '(\\s|$)', '')).match(s)) 
				{
					inAll = false; 
					break;
				}
            }
            if (inAll) return true;
        }
        return false;
    }

    public function removeClass(cssClass:String) : HaqQuery
    {
        cssClass = cssGlobalizer.className(cssClass);
        
		var classes = ~/\s+/.split(cssClass);
        for (node in nodes)
        {
            var s = node.hasAttribute('class') ? node.getAttribute('class') : '';
            for (c in classes)
			{
				s = (new EReg('(^|\\s)' + c + '(\\s|$)', '')).replace(s, ' ');
			}
            node.setAttribute('class', s.trim());
        }

        if (page.isPostback)
		{
			jQueryCall('removeClass("' + cssClass + '")');
		}

        return this;
    }

    /**
     * Get or set inner HTML.
     */
    public function html(html:String=null,isParse=false) : Dynamic
    {
        if (html == null)
        {
            if (nodes.length == 0) return null;
            var node = nodes[0];
            if (page.isPostback && node.name == 'textarea' && node.hasAttribute('id'))
            {
                var fullID = prefixID + node.getAttribute('id');
                if (page.params.exists(fullID))
				{
					return page.params.get(fullID);
				}
            }
            return node.innerHTML;
        }
        
        html = Std.string(html);
        for (node in nodes)
        {
            if (isParse) node.innerHTML = html;
            else         node.fastSetInnerHTML(html);
        }
        
        if (page.isPostback)
		{
			jQueryCall('html("' + StringTools.addcslashes(html) + '")');
		}
        
        return this;
    }

    public function remove() : HaqQuery
    {
        for (node in nodes)
        {
            node.remove();
        }
        
		if (page.isPostback)
		{
			jQueryCall('remove()');
		}
        
		return this;
    }

    /**
     * Get or set element value.
     */
    public function val(val:Dynamic=null) : Dynamic
    {
        // getting
        if (val == null)
        {
            if (nodes.length > 0)
            {
                /* @var $node HtmlNodeElement */
                var node : HtmlNodeElement = nodes[0];
                
                if (page.isPostback && node.hasAttribute('id'))
                {
                    var fullID = prefixID + node.getAttribute('id');
                    if (page.params.exists(fullID))
					{
						return page.params.get(fullID);
					}
                }
                
                if (node.name=='textarea') return node.innerHTML;
                
                if (node.name=='select')
                {
                    var options = node.find('>option');
                    for (option in options)
                    {
                        if (option.hasAttribute('selected')) return option.getAttribute ('value');
                    }
                    return null;
                }
                
                if (node.name=='input' && node.getAttribute('type')=='checkbox')
                {
                    if (!page.isPostback)
					{
						return node.hasAttribute('checked');
					}
					else
					{
						var fullID = prefixID + node.getAttribute('id');
						return Std.bool(page.params.get(fullID));
					}
                }
                
                return node.getAttribute('value');
            }
            else
            {
                // case when node physically not exists, but data received on postback
                if (page.isPostback)
                {
                    var re = new EReg('^\\s*#([^ \\t>]+)\\s*$', '');
                    if (re.match(query))
                    {
                        var fullID = prefixID + re.matched(1);
                        if (page.params.exists(fullID))
						{
							return page.params.get(fullID);
						}
                    }
                }
            }
            return null;
        }
        
        // setting
        for (node in nodes)
        {
            if (page.isPostback && node.hasAttribute('id'))
            {
                var fullID = prefixID + node.getAttribute('id');
				if (page.params.exists(fullID))
				{
					page.params.map.set(fullID, val);
				}
            }
            
            if (node.name == 'textarea')
            {
                node.innerHTML = Std.string(val);
            }
            else 
			if (node.name=='select')
            {
                var options = node.find('>option');
                for (option in options)
                {
                    if (option.getAttribute('value') == Std.string(val))
					{
                        option.setAttribute('selected', 'selected');
					}
                    else
					{
                        option.removeAttribute('selected');
					}
                }
            }
            else 
			if (node.name == 'input' && node.getAttribute('type') == 'checkbox')
            {
                if (Std.bool(val))
                {
                    node.setAttribute('checked', 'checked');
                }
                else
                {
                    node.removeAttribute('checked');
                }
            }
            else
            {
                node.setAttribute('value', Std.string(val));
            }
        }
        
        if (page.isPostback)
		{
			jQueryCall('val("' + val + '")');
		}

        return this;
    }

    /**
     * Get or set element's CSS style.
     */
    public function css(name:String, val:String=null) : Dynamic
    {
        if (val == null)
        {
            if (nodes.length > 0)
            {
                if (nodes[0].hasAttribute("style"))
				{
					var re = new EReg("(?:^|;)\\s*(?:" + name + ")\\s*:\\s*(.*?)\\s*(?:$|;)", "");
					if (re.match(nodes[0].getAttribute("style"))) return re.matched(1);
				}
            }
            return null;
        }

		for (node in nodes)
        {
			var style = node.hasAttribute("style") ? node.getAttribute("style") : "";
			var arr = style.split(";");
			var found = false;
			for (i in 0...arr.length)
			{
				var kv = arr[i].split(":");
				if (kv[0].trim() == name && kv.length > 1)
				{
					arr[i] = kv[0] + ":" + val;
					found = true;
					break;
				}
			}
			
			if (!found) arr.push(name + ":" + val);
			
            node.setAttribute("style", arr.join(";"));
        }

        if (page.isPostback)
		{
			jQueryCall('css("' + name + '","' + StringTools.addcslashes(val) +'")');
		}

        return this;
    }

    /**
     * Show element by setting display style to specified value.
     */
    public function show(display="") : HaqQuery
    {
        return css("display", display);
    }

    /**
     * Set "display" style to "none".
     */
    public function hide() : HaqQuery
    {
        return css("display", "none");
    }
    
    public function toggle(b:Bool) : HaqQuery
    {
        return css("display", b ? "" : "none");
    }
    
    /**
     * Call specified function for each selected element.
     */
    public function each(f:Int->HtmlNodeElement->Void)
    {
        for (i in 0...nodes.length)
        {
            f(i, get(i));
        }
    }
	
	public function data(name:String, ?val:Dynamic) : Dynamic
	{
		name = ~/[A-Z]/g.map(name, function(re) return "-" + re.matched(0).toLowerCase()).ltrim("-");
		if (val != null)
		{
			if (val == true) val = "true";
			else if (val == false) val = "false";
			return attr("data-" + name, Std.string(val));
		}
		else
		{
			return Std.parseValue(attr("data-" + name));
		}
	}
	
	public inline function iterator() : Iterator<HaqQuery>
	{
		return Lambda.map(nodes, function(node) return new HaqQuery(page, prefixID, cssGlobalizer, query, [node])).iterator();
	}
	
	public function find(selector:String) : HaqQuery
	{
		selector = selector.trim();
		var r = [];
		for (node in nodes)
		{
			r = r.concat(node.find(selector));
		}
		return new HaqQuery(page, prefixID, cssGlobalizer, query + (selector.startsWith(">") ? "" : " ") + selector, r);
	}
}
