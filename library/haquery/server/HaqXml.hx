package haquery.server;

import haxe.Serializer;
import haxe.Unserializer;

private typedef CssSelector =
{
	var type : String;
	var tags : Array<String>;
	var ids : Array <String>; 
	var classes : Array<String>;
}

private typedef HtmlLexem =
{
	var all : String;
	var allPos : Int;
	var script : String;
	var scriptAttrs : String;
	var scriptText : String;
	var style : String;
	var styleAttrs : String;
	var styleText : String;
	var elem : String;
	var tagOpen : String;
	var attrs : String;
	var tagEnd : String;
	var close : String;
	var tagClose : String;
	var comment : String;
}

class HaqXmlNode
{
    public var parent : HaqXmlNodeElement;
    
    public function remove() : Void
    {
        if (parent != null) parent.removeChild(this);
    }

    public function getPrevSiblingNode() : HaqXmlNode
    {
        if (parent == null) return null;
        var siblings = this.parent.nodes;
        var n = Lambda.indexOf(siblings, this);
        if (n <= 0) return null;
        if (n > 0) return siblings[n-1];
        return null;
    }
    
    public function getNextSiblingNode() : HaqXmlNode
    {
        if (parent == null) return null;
        var siblings = parent.nodes;
        var n = Lambda.indexOf(siblings, this);
        if (n<=0) return null;
        if (n+1 < siblings.length) return siblings[n+1];
        return null;
    }

	public function toString() : String
	{
		return '';
	}
	
	public function serialize() : String
	{
		var ser = new Serializer();
		ser.useCache = true;
		ser.serialize(this);
		return ser.toString();
	}
}

class HaqXmlNodeElement extends HaqXmlNode
{
    public var name : String;
    private var attributes : Hash<HaqXmlAttribute>;
    public var nodes : Array<HaqXmlNode>;
    public var children : Array<HaqXmlNodeElement>;
    
    public function getPrevSiblingElement() : HaqXmlNodeElement
    {
        if (parent == null) return null;
        var n = Lambda.indexOf(parent.children, this);
        if (n < 0) return null;
        if (n > 0) return parent.children[n - 1];
        return null;
    }

    public function getNextSiblingElement() : HaqXmlNodeElement
    {
        if (parent == null) return null;
        var n = Lambda.indexOf(parent.children, this);
        if (n < 0) return null;
        if (n + 1 < parent.children.length) return parent.children[n + 1];
        return null;
    }
    
	public function new(name:String, attributes:Hash<HaqXmlAttribute>)
    {
        this.name = name;
        this.attributes = attributes;
        this.nodes = [];
        this.children = [];
    }

    public function addChild(node:HaqXmlNode, beforeNode=null) : Void
    {
        node.parent = this;
        
		if (beforeNode == null)
        {
            nodes.push(node);
            if (Type.getClass(node) == HaqXmlNodeElement)
            {
                children.push(cast(node, HaqXmlNodeElement));
            }
        }
        else
        {
            var n = Lambda.indexOf(nodes, beforeNode);
            if (n >= 0)
            {
                nodes.insert(n, node);
                if (Type.getClass(node) == HaqXmlNodeElement)
                {
                    n = Lambda.indexOf(children, cast(beforeNode, HaqXmlNodeElement));
                    if (n >= 0)
                    {
                        children.insert(n, cast(node, HaqXmlNodeElement));
                    }
                }
            }
        }
    }

    public override function toString() 
    {
        var sAttrs = Lambda.array(Lambda.map(attributes, function(a) return a.toString())).join(' ');
		
        if (sAttrs != '')
		{
			sAttrs = ' '+sAttrs;
		}
        
        if (this.nodes.length == 0 && (Reflect.hasField(HaqXmlParser.getSelfClosingTags(), name) || name.indexOf(':') >= 0))
		{
			return "<" + name+sAttrs + " />";
		}
		
		for (child in children)
		{
			//Lib.println("child.name = " + child.name);
		}
        var sChildren = Lambda.array(Lambda.map(nodes, function(a) return a.toString())).join('');
		
        return name!=null && name!='' 
            ? "<" + name + sAttrs + ">" + sChildren + "</" + name + ">"
            : sChildren;
    }

    /*public function serialize() : String
    {
        return Serializer.run( { name : name, attributes:attributes, nodes:nodes  } );
    }

    public function unserialize(serialized) : Void
    {
        var clone : Dynamic = Unserializer.run(serialized);
		this.name = clone.name;
		this.attributes = clone.attributes;
        this.nodes = [];
        this.children = [];
		var nodes : Array<HaqXmlNode> = clone.nodes;
		
        for (node in nodes) this.addChild(node);
    }*/

	public function getAttribute(name:String) : String
	{
		var a = attributes.get(name);
		return a != null ? a.value : null;
	}

    public function setAttribute(name:String, value:String)
    {
        if (hasAttribute(name))
        {
			attributes.get(name).value = value;
        }
        else
        {
            attributes.set(name, new HaqXmlAttribute(name, value, '"'));
        }
    }

    public function removeAttribute(name:String)
    {
		attributes.remove(name);
    }

    public function hasAttribute(name:String) : Bool
    {
        return attributes.exists(name);//Lambda.exists(attributes, function(attr) return attr.name == name.toLowerCase() );
    }
    
    public var innerHTML(innerHTML_getter, innerHTML_setter) : String;
	
	function innerHTML_setter(value:String) : String
	{
		nodes = HaqXmlParser.parse(value);
		this.nodes = [];
		this.children = [];
		for (node in nodes) this.addChild(node);
		return value;
	}
	
	function innerHTML_getter() : String
    {
        return Lambda.fold(nodes, function(node, s) return s + node.toString(), "");
    }
    
    public function find(selector:String) : Array<HaqXmlNodeElement>
    {
        var parsedSelectors : Array<Array<CssSelector>> = HaqXmlParser.parseCssSelector(selector);

        var resNodes = new Array<HaqXmlNodeElement>();
        for (s in parsedSelectors)
        {
            for (node in children)
            {
                var nodesToAdd = node.findInner(s);
                for (nodeToAdd in nodesToAdd)
                {
                    if (!Lambda.has(resNodes, nodeToAdd))
                    {
                        resNodes.push(nodeToAdd);
                    }
                }
            }
        }
        return resNodes;
    }
    
    private function findInner(selectors:Array<CssSelector>) : Array<HaqXmlNodeElement>
    {
        if (selectors.length == 0)
		{
			return [];
		}
        
        var nodes = [];
        if (selectors[0].type == ' ') 
        {
            for (child in children) 
            {
                nodes = nodes.concat(child.findInner(selectors));
            }
        }
		
        if (isSelectorTrue(selectors[0]))
        {
            if (selectors.length == 1)
            {
                if (this.parent != null)
				{
					nodes.push(this);
				}

            }
            else
            {
                selectors.shift();
                for (child in children) 
                {
                    nodes = nodes.concat(child.findInner(selectors));
                }                    
            }
        }
        return nodes;
    }
    
    private function isSelectorTrue(selector:CssSelector)
    {
        for (tag in selector.tags) if (this.name != tag) return false;
        for (id in selector.ids) if (this.getAttribute('id') != id) return false;
        for (clas in selector.classes) 
		{
			var reg = new EReg("(?:^|\\s)" + clas + "(?:$|\\s)", "");
            if (!reg.match(getAttribute('class'))) return false;
		}
        return true;
    }
    
    public function replaceChild(node:HaqXmlNodeElement, newNode:HaqXmlNode)
    {
        newNode = Unserializer.run(newNode.serialize());
        newNode.parent = this;
        
        for (i in 0...nodes.length)
        {
            if (nodes[i] == node)
            {
                nodes[i] = newNode;
                break;
            }
        }
        
        var newNodeClass = Type.getClass(newNode);
		for (i in 0...children.length)
        {
            if (children[i] == node)
            {
                if (newNodeClass == HaqXmlNodeElement)
				{
					children[i] = cast(newNode, HaqXmlNodeElement);
				}
				else
				{
					children.splice(i, 1);
				}
                break;
            }
        }
    }
    
    public function replaceChildWithInner(node:HaqXmlNodeElement,  nodeContainer:HaqXmlNodeElement)
    {
        var nodeContainer : HaqXmlNodeElement = Unserializer.run(nodeContainer.serialize());
        
        for (n in nodeContainer.nodes)
		{
			n.parent = this;
		}
        
        for (i in 0...nodes.length)
        {
            if (nodes[i] == node)
            {
				var lastNodes = nodes.slice(i + 1, nodes.length);
				nodes = (i != 0 ? nodes.slice(0, i) : []).concat(nodeContainer.nodes).concat(lastNodes);
                break;
            }
        }
        
        for (i in 0...children.length)
        {
            if (children[i] == node)
            {
				var lastChildren = children.slice(i + 1, children.length);
				children = (i != 0 ? children.slice(0, i) : []).concat(nodeContainer.children).concat(lastChildren);
                break;
            }
        }
    }
	
	public function removeChild(node:HaqXmlNode)
    {
        var n = Lambda.indexOf(nodes, node);
        if (n >= 0) 
        {
            nodes.splice(n, 1);
			if (Type.getClass(node) == HaqXmlNodeElement)
			{
				n = Lambda.indexOf(children, cast(node, HaqXmlNodeElement));
				if (n >= 0 )
				{
					children.splice(n, 1);
				}
			}
        }
    }
    
    public function getAttributesAssoc() : Hash<String>
    {
        var attrs = new Hash<String>();
        for (attr in attributes)
        {
            attrs.set(attr.name, attr.value); 
        }
        return attrs;
    }

    public function setInnerText(text) : Void
    {
        this.nodes = [];
        this.children = [];
        this.addChild(new HaqXmlNodeText(text));
    }
}

class HaqXml extends HaqXmlNodeElement
{
    public function new(str='') : Void
    {
        super('', new Hash());
        var nodes = HaqXmlParser.parse(str);
        for (node in nodes)
		{
			addChild(node);
		}
    }
}

class HaqXmlNodeText extends HaqXmlNode
{
    public var text : String;

    public function new(text) : Void
    {
        this.text = text;
    }
 
	public override function toString()
    {
        return this.text;
    }
}

class HaqXmlAttribute
{
    public var name :String;
    public var value :String;
    public var quote :String;

    public function new(name, value, quote) : Void
    {
        this.name = name;
        this.value = value;
        this.quote = quote;
    }
    
	public function toString()
    {
        return name + "=" + quote + value + quote;
    }
}

class HaqXmlParser
{
    public static function getSelfClosingTags() { return { img:1, br:1, input:1, meta:1, link:1, hr:1, base:1, embed:1, spacer:1 }; }
    private static function getRegExpForID() { return '[a-z](?:-?[_a-z0-9])*'; }

    static public function parse(str:String) : Array<HaqXmlNode>
    {
        var reID = getRegExpForID();
        var reAttr = getRegExpForID() + "\\s*=\\s*(?:'[^']*'|\"[^\"]*\"|[-_a-z0-9]+)" ;

        var reElementName = reID + "(?::" + reID + ")?";
		
		var reScript = "[<]\\s*script\\s*(?<scriptAttrs2>[^>]*)>(?<scriptText3>.*?)<\\s*/\\s*script\\s*>";
		var reStyle = "<\\s*style\\s*(?<styleAttrs5>[^>]*)>(?<styleText6>.*?)<\\s*/\\s*style\\s*>";
		var reElementOpen = "<\\s*(?<tagOpen8>" + reElementName+ ")";
        var reAttr = reID + "\\s*=\\s*(?:'[^']*'|\"[^\"]*\"|[-_a-z0-9]+)";
        var reElementEnd = "(?<tagEnd10>/)?\\s*>";
        var reElementClose = "<\\s*/\\s*(?<tagClose12>" + reElementName + ")\\s*>";
        
        
        var reComment = "<!--.*?-->";

        var re = new EReg(
				 "(?<script1>" + reScript + ")|(?<style4>" + reStyle + ")|(?<elem7>" + reElementOpen 
		       + "(?<attrs9>(?:\\s+" + reAttr +")*)\\s*" + reElementEnd + ")|(?<close11>" + reElementClose + ")|(?<comment13>" + reComment + ")", "is"
		);
		
		var matches = new Array<HtmlLexem>();
		var parsedStr : String = str;
		var cutted = 0;
		while (parsedStr != null && parsedStr != "" && re.match(parsedStr))
		{
			var r = {
				 all : re.matched(0)
				,allPos : re.matchedPos().pos + cutted
				,script : getMatched(re, 1)
				,scriptAttrs : getMatched(re, 2)
				,scriptText : getMatched(re, 3)
				,style : getMatched(re, 4)
				,styleAttrs : getMatched(re, 5)
				,styleText : getMatched(re, 6)
				,elem : getMatched(re, 7)
				,tagOpen : getMatched(re, 8)
				,attrs : getMatched(re, 9)
				,tagEnd : getMatched(re, 10)
				,close : getMatched(re, 11)
				,tagClose : getMatched(re, 12)
				,comment : getMatched(re, 13)
			};
			//Lib.println("r.allPos = " + r.allPos);
			
			matches.push(r);
			
			var rightStr = re.matchedRight();
			cutted += parsedStr.length - rightStr.length;
			parsedStr = rightStr;
		}
        
		if (matches.length > 0)
        {
            var i = { i:0 };
			var nodes =  parseInner(str,  matches, i);
            if (i.i < matches.length)
			{
				throw("Error parsing XML:\n<br>" + str);
			}
            return nodes;
        }
		
        return str.length > 0 ? cast [ new HaqXmlNodeText(str) ] : [];
    }
	
	
	static function getMatched(re:EReg, n:Int)
	{
		try { return re.matched(n); } 
		catch (e:Dynamic) { return null; }
	}
	
	private static function parseInner(str:String, matches:Array<HtmlLexem>, i:{i:Int}) : Array<HaqXmlNode>
    {
        //Lib.println("parseInner(" + str + ", " + matches.length + ", " + i.i + ")");
        
		var nodes = new Array<HaqXmlNode>();
        
		var prevEnd = i.i > 0 ? matches[i.i - 1].allPos + matches[i.i - 1].all.length : 0;
		//Lib.println("prevEnd = " + prevEnd);
        var curStart = matches[i.i].allPos;
		//Lib.println("curStart = " + curStart);
        
		if (prevEnd < curStart)
        {
            nodes.push(new HaqXmlNodeText(str.substr(prevEnd, curStart - prevEnd)));
        }

        while (i.i < matches.length)
        {
			//Lib.println("i = " + i);
            var m = matches[i.i];
			//Lib.println("m = " + m.all);
			//Lib.println("1nodes = " + nodes.length);			
            
			if (m.elem != null && m.elem != '')
            {
				nodes.push(parseElement(str, matches, i));
				//Lib.println("5nodes = " + nodes.length);
            }
            else
            if (m.script != null && m.script != '')
            {
                var scriptNode = new HaqXmlNodeElement('script', parseAttrs(m.scriptAttrs));
                scriptNode.addChild(new HaqXmlNodeText(m.scriptText));
                nodes.push(scriptNode);
            }
            else
            if (m.style != null && m.style != '')
            {
                var styleNode = new HaqXmlNodeElement('style', parseAttrs(m.styleAttrs));
                styleNode.addChild(new HaqXmlNodeText(m.styleText));
                nodes.push(styleNode);
            }
            else
            if (m.close != null && m.close != '') break;
            else
            if (m.comment != null && m.comment != '')
            {
                nodes.push(new HaqXmlNodeText(m.comment));
            }
            else
            {
                throw("Error");
            }
            
			//Lib.println("2nodes = " + nodes.length);			
			
			var curEnd = matches[i.i].allPos + matches[i.i].all.length;
			//trace("curEnd = " + curEnd);
			//trace("matches.length = " + matches.length);
            var nextStart = i.i + 1 < matches.length ? matches[i.i + 1].allPos : str.length;
			//trace("nextStart = " + nextStart);
            if (curEnd < nextStart)
            {
                nodes.push(new HaqXmlNodeText(str.substr(curEnd, nextStart - curEnd)));
            }
			
			//Lib.println("3nodes = " + nodes.length);			
			
			i.i++;
        }
		
		//Lib.println("i = " + i);
		//Lib.println("4nodes = " + nodes.length);
        
		return nodes;
    }

    private static function parseElement(str, matches:Array<HtmlLexem>, i:{i:Int}) : HaqXmlNodeElement
    {
        //Lib.println("parseElement(" + str + ", " + matches.length + ", " + i.i + ")");
		
		var tag = matches[i.i].tagOpen;
        var attrs = matches[i.i].attrs;
        var isWithClose = matches[i.i].tagEnd != null || Reflect.hasField(getSelfClosingTags(), tag);
		
        var elem = new HaqXmlNodeElement(tag, parseAttrs(attrs));
        if (!isWithClose)
        {
            i.i++;
            var nodes = parseInner(str, matches, i);
            for (node in nodes) elem.addChild(node);
            if (matches[i.i].close == null || matches[i.i].close == '' || matches[i.i].tagClose != tag)
			{
                throw("XML parse error: tag <" + tag + "> not closed. ParsedText = \n<pre>" + str + "</pre>\n");
			}
        }

        return elem;
    }

    private static function parseAttrs(str:String) : Hash<HaqXmlAttribute>
    {
        var attributes = new Hash<HaqXmlAttribute>();

		var re = new EReg("(?<name>" + getRegExpForID() + ")\\s*=\\s*(?<value>'[^']*'|\"[^\"]*\"|[-_a-z0-9]+)" , "is");
		var parsedStr = str;
        while (parsedStr != null && parsedStr != '' && re.match(parsedStr))
        {
			var name =  re.matched(1);
			var value = re.matched(2);
			var quote = value.substr(0, 1);
			if (quote == '"' || quote == "'")
			{
				value = value.substr(1, value.length - 2);
			}
			else
			{
				quote = '';
			}
			attributes.set(name.toLowerCase(), new HaqXmlAttribute(name, value, quote));
			parsedStr = re.matchedRight();
        }

        return attributes;
    }
    
    static public function parseCssSelector(selector : String) : Array<Array<CssSelector>>
    {
		var reg : EReg = new EReg('\\s*,\\s*', "");
        var selectors = reg.split(selector);
        var r = [];
        for (s in selectors)
        {
            if (s != "")
			{
				r.push(parseCssSelectorInner(s));
			}
        }
        return r;
    }
    
    private static function parseCssSelectorInner(selector): Array<CssSelector>
    {
        var reSubSelector = '[.#]?'+/*self.*/getRegExpForID()+'(?::'+/*self.*/getRegExpForID()+')?';
        
        var parsedSelectors = [];
		var reg : EReg = new EReg("(?<type>[ >])(?<selector>(?:" + reSubSelector + ")+|[*])", "is");
		
		var strSelector = ' ' + selector;
        while(reg.match(strSelector))
        {
			var tags = [];
			var ids = [];
			var classes = [];
			if (reg.matched(2)!='*')
			{
				var subreg : EReg = new EReg(reSubSelector, "is");
				var substr = reg.matched(2);
				while(subreg.match(substr))
				{
					var s :String = subreg.matched(0);
					if      (s.substr(0, 1)=="#") ids.push(s.substr(1));
					else if (s.substr(0, 1)==".") classes.push(s.substr(1));
					else                          tags.push( (s.toLowerCase()));
					substr = subreg.matchedRight();
				}
			}
			parsedSelectors.push({ 
				type:reg.matched(1), 
				tags:tags, 
				ids:ids, 
				classes:classes
			});
			strSelector = reg.matchedRight();
        }
        return parsedSelectors;
    }
}
