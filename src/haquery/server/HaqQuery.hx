package haquery.server;

import php.Lib;
import php.NativeArray;
import haquery.server.HaqXml;
import haquery.server.HaQuery;

/**
 * Серверный (php-шный) аналог jQuery.
 */
class HaqQuery
{
    public var prefixID : String;
    
    /**
     * Исходная строка с CSS-селекторами.
     * @var string 
     */
    public var query : String;
    
    /**
     * @var HaqXmlNodeElement[]
     */
    public var nodes : Array<HaqXmlNodeElement>;
    
    private function jQueryCall(method)
    {
        HaqInternals.addAjaxAnswer("$('"+this.query.replace('#', '#'+this.prefixID)+"')." + method + ";");
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

    /**
     * Возвращает количество выбранных DOM-элементов.
     * @return int
     */
    public function size() { return this.nodes.length; }

    /**
     * Возвращает либо массив выбранных DOM-элементов (если не задан параметр index),
     * либо один элемент этого массива с указанным индексом.
     * @param int $index Индекс элемента.
     * @return HaqNode
     */
    public function get(index=null)
    {
        return untyped __physeq__(index, null) ? this.nodes : this.nodes[index];
    }

    /**
     * Меняет или возвращает значение атрибута.
     * @param string $name Название атрибута.
     * @param string $value Новое значение атрибута.
     * @return HaqQuery
     */
    public function attr(name:String, value:String=null) : Dynamic
    {
        if (untyped __physeq__(value, null))
		{
			return this.nodes.length>0 ? this.nodes[0].getAttribute(name) : null;
		}
        for (node in this.nodes) node.setAttribute(name, value);
        if (HaQuery.isPostback) this.jQueryCall('attr("'+name+'","'+value+'")');
        return this;
    }

    /**
     * Удаляет заданный атрибут из выбранных тегов.
     * @param string $name Название атрибута.
     * @return HaqQuery
     */
    public function removeAttr(name:String) : HaqQuery
    {
        for (node in this.nodes) node.removeAttribute(name);
        if (HaQuery.isPostback) HaqInternals.addAjaxAnswer ("$('"+this.query.replace('#', '#'+this.prefixID)+"').removeAttr('" + name + "');");
        return this;
    }

    /**
     * Добавляет заданные классы в свойство class.
     * @param string $class
     * @return HaqQuery
     */
    public function addClass(clas:String) : HaqQuery
    {
        var classes = (new EReg('\\s+', '')).split(clas);
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

        if (HaQuery.isPostback) this.jQueryCall('addClass("'+clas+'")');

        return this;
    }

    /**
     * Проверяет наличие всех заданных классов хотя бы у одного из выбранных элементов.
     * @param string $class Названия классов, разделённые пробелом.
     * @return bool
     */
    public function hasClass(clas:String) : Bool
    {
        var classes = (new EReg('\\s+', '')).split(clas);
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

    /**
     * Удаляет заданные классы из атрибута class.
     * @param string $class Задаёт имена CSS-классов, которые нужно удалить (разделённые пробелом).
     * @return HaqQuery
     */
    public function removeClass(clas:String) : HaqQuery
    {
        var classes = (new EReg('\\s+', '')).split(clas);
        for (node in this.nodes)
        {
            var s = node.hasAttribute('class') ? node.getAttribute('class') : '';
            for (c in classes) s = (new EReg('(^|\\s)' + c + '(\\s|$)', '')).replace(s, ' ');
            node.setAttribute('class', s.trim());
        }

        if (HaQuery.isPostback) this.jQueryCall('removeClass("'+clas+'")');

        return this;
    }

    /**
     * Меняет или возвращает HTML, вписанный в первый выбранный элемент.
     * @param string $html Новый html-текст.
     * @param string $isParse Нужно ли преобразовывать текст в XML-поддерево. По-умолчанию текст запишется просто как узел XmlNodeText.
     * @return HaqQuery
     */
    public function html(html:String=null,isParse=false) : Dynamic
    {
        if (untyped __physeq__(html, null)) return this.nodes.length > 0 ? this.nodes[0].innerHTML : null;
        for (node in this.nodes)
        {
            if (isParse) node.innerHTML = html;
            else         node.setInnerText(html);
        }
        
        if (HaQuery.isPostback) this.jQueryCall('html("' + HaQuery.jsEscape(html) + '")');
        
        return this;
    }

    /**
     * Полностью удаляет элемент.
     * @return HaqQuery
     */
    public function remove() : HaqQuery
    {
        for (node in this.nodes) node.remove();
        if (HaQuery.isPostback) this.jQueryCall('remove()');
        return this;
    }

    /**
     * Меняет или возвращает значение первого выбранного элемента
     * (подразумевается, что это элемент input или textarea).
     * @param string $val Новое значение.
     * @return HaqQuery
     */
    public function val(val:String=null) : Dynamic
    {
        // getting
        if (untyped __physeq__(val, null))
        {
            if (this.nodes.length > 0)
            {
                /* @var $node HaqXmlNodeElement */
                var node : HaqXmlNodeElement = this.nodes[0];
                
                if (HaQuery.isPostback && node.hasAttribute('id'))
                {
                    var fullID = this.prefixID + node.getAttribute('id');
                    if (/*$_POST*/php.Web.getParams().exists(fullID)) return /*$_POST*/php.Web.getParams().get(fullID);
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
                
                return node.getAttribute('value');
            }
            return null;
        }
        
        // setting
        for (node in this.nodes)
        {
            if (HaQuery.isPostback && node.hasAttribute('id'))
            {
                var fullID = this.prefixID + node.getAttribute('id');
				untyped __php__("
					if (isset($_POST[$fullID])) $_POST[$fullID] = $val; 
				");
            }
            
            if (node.name=='textarea') node.innerHTML = val;
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
            else node.setAttribute('value',val);
        }
        
        if (HaQuery.isPostback) this.jQueryCall('val("' + val + '")');

        return this;
    }

    /**
     * Меняет или возвращает один из CSS-стилей выбранных элементов.
     * @param string $name Название стиля.
     * @param string $val Новое значение для стиля.
     * @return HaqQuery
     */
    public function css(name:String, val:String=null) : Dynamic
    {
        if (untyped __phyeq(val, null))
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

        if (HaQuery.isPostback) this.jQueryCall('css("' + name + '","' + HaQuery.jsEscape(val) +'")');

        return this;
    }

    /**
     * Показывает элементы, убирая из их атрибутов style параметр display.
     * @param string $display Как показывать элемент: "" (автоматически), "inline" (строковым) или "block" (блочным).
     * @return HaqQuery
     */
    public function show(display='') : HaqQuery
    {
        return this.css('display',display);
    }

    /**
     * Прячет элементы, задавая их атрибутам style параметр display:none.
     * @return HaqQuery
     */
    public function hide() : HaqQuery
    {
        return this.css('display','none');
    }
}
