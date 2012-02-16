package haquery.server;

import haquery.server.Lib;
import haquery.server.HaqXml;
import haquery.Std;

using haquery.StringTools;

/**
 * Like $ in jQuery.
 */
class HaqQuery
{
    public var prefixCssClass : String;
    public var prefixID : String;
    
    /**
     * Original CSS-selector.
     */
    public var query : String;
    
    /**
     * Selected XML DOM nodes (elements).
     */
    public var nodes(default, null) : Array<HaqXmlNodeElement>;
    
    function jQueryCall(method)
    {
        HaqInternals.addAjaxResponse("$('" + query.replace('#', '#' + prefixID) + "')." + method + ";");
    }
    
	function globalizeClassName(className:String) : String
	{
        return ~/\b~/.replace(className, prefixCssClass);
	}
    
	public function new(prefixCssClass:String, prefixID:String, query:String, nodes:Array<HaqXmlNodeElement>)
    {
        this.prefixCssClass = prefixCssClass;
		this.prefixID = prefixID;
        this.query = query;
        this.nodes = nodes != null ? nodes : [];
    }
	
    public function __toString()
    {
        return nodes.join('');
    }

    public function size() : Int { return nodes.length; }

    public function get(index:Int) : HaqXmlNodeElement
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
			HaqInternals.addAjaxResponse ("$('" + query.replace('#', '#' + prefixID) + "').removeAttr('" + name + "');");
		}
        
		return this;
    }

    public function addClass(cssClass:String) : HaqQuery
    {
        cssClass = globalizeClassName(cssClass);
		
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
        cssClass = globalizeClassName(cssClass);
        
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
        cssClass = globalizeClassName(cssClass);
        
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
                if (Web.getParams().exists(fullID))
				{
					return Web.getParams().get(fullID);
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
                /* @var $node HaqXmlNodeElement */
                var node : HaqXmlNodeElement = nodes[0];
                
                if (Lib.isPostback && node.hasAttribute('id'))
                {
                    var fullID = prefixID + node.getAttribute('id');
                    if (Web.getParams().exists(fullID))
					{
						return Web.getParams().get(fullID);
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
						return Std.bool(Web.getParams().get(fullID));
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
                        if (Web.getParams().exists(fullID))
						{
							return Web.getParams().get(fullID);
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
				untyped __php__("
					if (isset($_POST[$fullID])) $_POST[$fullID] = $val; 
				");
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
        
        if (Lib.isPostback) jQueryCall('val("' + val + '")');

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
                var sStyles = nodes[0].getAttribute('style');
                
				//if (preg_match("/\b(" + name + ")\b\s*:\s*(.*?)\s*;/", sStyles, matches)) return matches[1];
				var re : EReg = new EReg("\\b(" + name + ")\\b\\s*:\\s*(.*?)\\s*;", '');
				if (re.match(sStyles)) return re.matched(1);
            }
            return null;
        }

        var re = new EReg("\\b(" + name + ")\\b\\s*:\\s*(.*?)\\s*(;|$)", '');
		for (node in nodes)
        {
            var sStyles = nodes[0].getAttribute('style');
			if (re.match(sStyles))
			{
				sStyles = re.replace((val != '' && val != null) ? name + ": " + val + ";" : '', sStyles);
			}
			else
			{
				if (untyped !__physeq__(val, '') && !__physeq__(val, null)) sStyles =  name + ": " + val + "; " + sStyles;
			}
            nodes[0].setAttribute('style', sStyles);
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
    public function show(display='') : HaqQuery
    {
        return css('display',display);
    }

    /**
     * Set "display" style to "none".
     */
    public function hide() : HaqQuery
    {
        return css('display','none');
    }
    
    /**
     * Call specified function for each selected element.
     */
    public function each(f:Int->HaqXmlNodeElement->Void)
    {
        for (i in 0...nodes.length)
        {
            f(i, get(i));
        }
    }
}
