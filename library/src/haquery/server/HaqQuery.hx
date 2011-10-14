package haquery.server;

import haquery.server.Lib;
import haquery.server.HaqXml;
import php.Lib;
import php.NativeArray;
using haquery.StringTools;

/**
 * Like $ in jQuery.
 */
class HaqQuery
{
    public var prefixID : String;
    
    /**
     * Original CSS-selector.
     */
    public var query : String;
    
    /**
     * Selected XML DOM nodes (elements).
     */
    public var nodes(default, null) : Array<HaqXmlNodeElement>;
    
    private function jQueryCall(method)
    {
        HaqInternals.addAjaxResponse("$('" + query.replace('#', '#' + prefixID) + "')." + method + ";");
    }
    
    public function new(prefixID:String, query:String, nodes:NativeArray)
    {
        this.prefixID = prefixID;
        this.query = query;
        this.nodes = nodes!=null ? untyped Lib.toHaxeArray(nodes) : new Array<HaqXmlNodeElement>();
    }

    public function __toString()
    {
        return this.nodes.join('');
    }

    public function size() : Int { return this.nodes.length; }

    public function get(index:Int) : HaqXmlNodeElement
    {
        return this.nodes[index];
    }

    /**
     * Get or set attribute value.
     */
    public function attr(name:String, value:String=null) : Dynamic
    {
        if (untyped __physeq__(value, null))
		{
			return this.nodes.length>0 ? this.nodes[0].getAttribute(name) : null;
		}
        for (node in this.nodes) node.setAttribute(name, value);
        if (HaqSystem.isPostback) this.jQueryCall('attr("'+name+'","'+value+'")');
        return this;
    }

    public function removeAttr(name:String) : HaqQuery
    {
        for (node in this.nodes) node.removeAttribute(name);
        if (HaqSystem.isPostback) HaqInternals.addAjaxResponse ("$('"+this.query.replace('#', '#'+this.prefixID)+"').removeAttr('" + name + "');");
        return this;
    }

    public function addClass(cssClass:String) : HaqQuery
    {
        var classes = (new EReg('\\s+', '')).split(cssClass);
        for (node in this.nodes)
        {
            var s = node.hasAttribute('class') ? node.getAttribute('class') : '';
            for (c in classes)
            {
                //assert(c!='');
                if (!(new EReg('(^|\\s)'+c+'(\\s|$)', '')).match(s)) s += " " + c;
            }
            node.setAttribute('class', s.ltrim());
        }

        if (HaqSystem.isPostback) this.jQueryCall('addClass("'+cssClass+'")');

        return this;
    }

    public function hasClass(cssClass:String) : Bool
    {
        var classes = (new EReg('\\s+', '')).split(cssClass);
        for (node in this.nodes)
        {
            var s = node.hasAttribute('class') ? node.getAttribute('class') : '';
            var inAll = true;
            for (c in classes)
            {
                //assert(c!='');
                if (!(new EReg('(^|\\s)'+c+'(\\s|$)', '')).match(s)) { inAll = false; break; }
            }
            if (inAll) return true;
        }
        return false;
    }

    public function removeClass(cssClass:String) : HaqQuery
    {
        var classes = (new EReg('\\s+', '')).split(cssClass);
        for (node in this.nodes)
        {
            var s = node.hasAttribute('class') ? node.getAttribute('class') : '';
            for (c in classes) s = (new EReg('(^|\\s)' + c + '(\\s|$)', '')).replace(s, ' ');
            node.setAttribute('class', s.trim());
        }

        if (HaqSystem.isPostback) this.jQueryCall('removeClass("'+cssClass+'")');

        return this;
    }

    /**
     * Get or set inner HTML.
     */
    public function html(html:String=null,isParse=false) : Dynamic
    {
        if (html == null)
        {
            if (this.nodes.length == 0) return null;
            var node = this.nodes[0];
            if (HaqSystem.isPostback && node.name == 'textarea' && node.hasAttribute('id'))
            {
                var fullID = prefixID + node.getAttribute('id');
                if (php.Web.getParams().exists(fullID)) return php.Web.getParams().get(fullID);
            }
            return node.innerHTML;
        }
        for (node in this.nodes)
        {
            if (isParse) node.innerHTML = html;
            else         node.setInnerText(html);
        }
        
        if (HaqSystem.isPostback) this.jQueryCall('html("' + StringTools.addcslashes(html) + '")');
        
        return this;
    }

    public function remove() : HaqQuery
    {
        for (node in this.nodes) node.remove();
        if (HaqSystem.isPostback) this.jQueryCall('remove()');
        return this;
    }

    /**
     * Get or set element value.
     */
    public function val(val:Dynamic=null) : Dynamic
    {
        // getting
        if (untyped __physeq__(val, null))
        {
            if (this.nodes.length > 0)
            {
                /* @var $node HaqXmlNodeElement */
                var node : HaqXmlNodeElement = this.nodes[0];
                
                if (HaqSystem.isPostback && node.hasAttribute('id'))
                {
                    var fullID = prefixID + node.getAttribute('id');
                    if (php.Web.getParams().exists(fullID)) return php.Web.getParams().get(fullID);
                }
                
                if (node.name=='textarea') return node.innerHTML;
                
                if (node.name=='select')
                {
                    var options : Array<HaqXmlNodeElement> = untyped Lib.toHaxeArray(node.find('>option'));
                    for (option in options)
                    {
                        if (option.hasAttribute('selected')) return option.getAttribute ('value');
                    }
                    return null;
                }
                
                if (node.name=='input' && node.getAttribute('type')=='checkbox')
                {
                    return node.hasAttribute('checked');
                }
                
                return node.getAttribute('value');
            }
            else
            {
                // case when node physically not exists, but data received on postback
                if (HaqSystem.isPostback)
                {
                    var re = new EReg('^\\s*#([^ \\t>]+)\\s*$', '');
                    if (re.match(query))
                    {
                        var fullID = prefixID + re.matched(1);
                        if (php.Web.getParams().exists(fullID)) return php.Web.getParams().get(fullID);
                    }
                }
            }
            return null;
        }
        
        // setting
        for (node in this.nodes)
        {
            if (HaqSystem.isPostback && node.hasAttribute('id'))
            {
                var fullID = this.prefixID + node.getAttribute('id');
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
                var options : Array<HaqXmlNodeElement> = untyped Lib.toHaxeArray(node.find('>option'));
                for (option in options)
                {
                    if (option.getAttribute('value')==val)
                        option.setAttribute('selected','selected');
                    else
                        option.removeAttribute('selected');
                }
            }
            else 
			if (node.name == 'input' && node.getAttribute('type') == 'checkbox')
            {
                if (HaqTools.bool(val))
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
                node.setAttribute('value',val);
            }
        }
        
        if (HaqSystem.isPostback) this.jQueryCall('val("' + val + '")');

        return this;
    }

    /**
     * Get or set element's CSS style.
     */
    public function css(name:String, val:String=null) : Dynamic
    {
        if (untyped __physeq__(val, null))
        {
            if (this.nodes.length > 0)
            {
                var sStyles = this.nodes[0].getAttribute('style');
                
				//if (preg_match("/\b(" + name + ")\b\s*:\s*(.*?)\s*;/", sStyles, matches)) return matches[1];
				var re : EReg = new EReg("\\b(" + name + ")\\b\\s*:\\s*(.*?)\\s*;", '');
				if (re.match(sStyles)) return re.matched(1);
            }
            return null;
        }

        var re = new EReg("\\b(" + name + ")\\b\\s*:\\s*(.*?)\\s*(;|$)", '');
		for (node in this.nodes)
        {
            var sStyles = this.nodes[0].getAttribute('style');
			if (re.match(sStyles))
			{
				sStyles = re.replace(untyped !__physeq__(val, '') && !__physeq__(val, null) ? name + ": " + val + ";" : '', sStyles);
			}
			else
			{
				if (untyped !__physeq__(val, '') && !__physeq__(val, null)) sStyles =  name + ": " + val + "; " + sStyles;
			}
            this.nodes[0].setAttribute('style', sStyles);
        }

        if (HaqSystem.isPostback) this.jQueryCall('css("' + name + '","' + StringTools.addcslashes(val) +'")');

        return this;
    }

    /**
     * Show element by setting display style to specified value.
     */
    public function show(display='') : HaqQuery
    {
        return this.css('display',display);
    }

    /**
     * Set "display" style to "none".
     */
    public function hide() : HaqQuery
    {
        return this.css('display','none');
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
