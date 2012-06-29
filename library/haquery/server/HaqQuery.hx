package haquery.server;

import haquery.Std;
import haxe.htmlparser.HtmlNodeElement;
import haquery.base.HaqCssGlobalizer;
import haquery.server.Lib;

using haquery.StringTools;

/**
 * Like $ in jQuery.
 */
class HaqQuery
{
    public var cssGlobalizer(default, null) : HaqCssGlobalizer;
    public var prefixID(default, null) : String;
	
	/**
     * Original CSS-selector.
     */
    public var query : String;
    
    /**
     * Selected XML DOM nodes (elements).
     */
    public var nodes(default, null) : Array<HtmlNodeElement>;
    
    function jQueryCall(method)
    {
        HaqSystem.addAjaxResponse("$('" + query.replace('#', '#' + prefixID) + "')." + method + ";");
    }
    
	public function new(cssGlobalizer:HaqCssGlobalizer, prefixID:String, query:String, nodes:Array<HtmlNodeElement>)
    {
        this.cssGlobalizer = cssGlobalizer;
		this.prefixID = prefixID;
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
        
		if (Lib.isPostback)
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
        
		if (Lib.isPostback)
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

        if (Lib.isPostback)
		{
			jQueryCall('addClass("' + cssClass + '")');
		}

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

        if (Lib.isPostback)
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
            if (Lib.isPostback && node.name == 'textarea' && node.hasAttribute('id'))
            {
                var fullID = prefixID + node.getAttribute('id');
                if (Lib.params.exists(fullID))
				{
					return Lib.params.get(fullID);
				}
            }
            return node.innerHTML;
        }
        
        html = Std.string(html);
        for (node in nodes)
        {
            if (isParse) node.innerHTML = html;
            else         node.setInnerText(html);
        }
        
        if (Lib.isPostback)
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
        
		if (Lib.isPostback)
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
                
                if (Lib.isPostback && node.hasAttribute('id'))
                {
                    var fullID = prefixID + node.getAttribute('id');
                    if (Lib.params.exists(fullID))
					{
						return Lib.params.get(fullID);
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
                    if (!Lib.isPostback)
					{
						return node.hasAttribute('checked');
					}
					else
					{
						var fullID = prefixID + node.getAttribute('id');
						return Std.bool(Lib.params.get(fullID));
					}
                }
                
                return node.getAttribute('value');
            }
            else
            {
                // case when node physically not exists, but data received on postback
                if (Lib.isPostback)
                {
                    var re = new EReg('^\\s*#([^ \\t>]+)\\s*$', '');
                    if (re.match(query))
                    {
                        var fullID = prefixID + re.matched(1);
                        if (Lib.params.exists(fullID))
						{
							return Lib.params.get(fullID);
						}
                    }
                }
            }
            return null;
        }
        
        // setting
        for (node in nodes)
        {
            if (Lib.isPostback && node.hasAttribute('id'))
            {
                var fullID = prefixID + node.getAttribute('id');
				if (Lib.params.exists(fullID))
				{
					Lib.params.set(fullID, val);
				}
            }
            
            if (node.name == 'textarea')
            {
                node.innerHTML = val;
            }
            else 
			if (node.name=='select')
            {
                var options = node.find('>option');
                for (option in options)
                {
                    if (option.getAttribute('value') == val)
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
                node.setAttribute('value', val);
            }
        }
        
        if (Lib.isPostback)
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
					var re = new EReg("\\b(" + name + ")\\b\\s*:\\s*(.*?)\\s*;", '');
					if (re.match(nodes[0].getAttribute("style"))) return re.matched(1);
				}
            }
            return null;
        }

        var re = new EReg("\\b(" + name + ")\\b\\s*:\\s*(.*?)\\s*(;|$)", '');
		for (node in nodes)
        {
			var sStyles = node.hasAttribute("style") ? node.getAttribute("style") : "";
			if (re.match(sStyles))
			{
				sStyles = re.replace((val != '' && val != null) ? name + ": " + val + ";" : '', sStyles);
			}
			else
			{
				if (val != null && val != '')
				{
					sStyles =  name + ": " + val + "; " + sStyles;
				}
			}
            node.setAttribute("style", sStyles);
        }

        if (Lib.isPostback)
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
		if (val != null)
		{
			if      (val == true)	val = "true";
			else if (val == false)	val = "false";
			return attr("data-" + name, val);
		}
		else
		{
			val = attr("data-" + name);
			if (val == "true") return true;
			if (val == "false") return false;
			if (val == "0") return 0;
			var n = Std.parseInt(val);
			if (n != 0 && n != null) return n;
			var f = Std.parseFloat(val);
			if (f != 0 && f != null) return n;
			return val;
		}
	}
}
