<?php
abstract class HaqXmlNode implements Serializable
{
    /**
     * @var HaqXmlNodeElement
     */
    public $parent;
    
    function remove()
    {
        if ($this->parent) $this->parent->removeChild($this);
    }

    /**
     * @return HaqXmlNode
     */
    function getPrevSiblingNode()
    {
        if (!$this->parent) return null;
        $siblings = $this->parent->nodes;
        $n = array_search($this, $siblings, true);
        if ($n===false) return null;
        if ($n > 0) return $siblings[$n-1];
        return null;
    }
    
    /**
     * @return HaqXmlNode
     */
    function getNextSiblingNode()
    {
        if (!$this->parent) return null;
        $siblings = $this->parent->nodes;
        $n = array_search($this, $siblings, true);
        if ($n===false) return null;
        if ($n+1 < count($siblings)) return $siblings[$n+1];
        return null;
    }
    /**
     * @return HaqXmlNodeElement
     */
    function getPrevSiblingElement()
    {
        if (!$this->parent) return null;
        $siblings = $this->parent->children;
        $n = array_search($this, $siblings, true);
        if ($n===false) return null;
        if ($n > 0) return $siblings[$n-1];
        return null;
    }

    /**
     * @return HaqXmlNodeElement
     */
    function getNextSiblingElement()
    {
        if (!$this->parent) return null;
        $siblings = $this->parent->children;
        $n = array_search($this, $siblings, true);
        if ($n===false) return null;
        if ($n+1 < count($siblings)) return $siblings[$n+1];
        return null;
    }
}

/**
 * @property string innerHTML
 */
class HaqXmlNodeElement extends HaqXmlNode
{
    /**
     * @var string
     */
    public $name;

    /**
     * @var HaqXmlAttribute[]
     */
    private $attributes;

    /**
     * @var HaqXmlNode[]
     */
    public $nodes;

    /**
     * @var HaqXmlNodeElement[]
     */
    public $children;
    
    /**
     * @var HaqComponent
     */
    public $component;

    /**
     * @param string $name Тег.
     * @param array $attributes Ассоциативный массив атрибутов.
     */
    function __construct($name, $attributes)
    {
        $this->name = $name;
        $this->attributes = $attributes;
        $this->nodes = array();
        $this->children = array();
    }

    function addChild($node, $beforeNode=null)
    {
        $node->parent = $this;
        if ($beforeNode == null)
        {
            array_push($this->nodes, $node);
            if ($node instanceof HaqXmlNodeElement)
            {
                array_push($this->children, $node);
            }
        }
        else
        {
            $n = array_search($beforeNode, $this->nodes, true);
            if ($n!==false)
            {
                array_splice($this->nodes, $n, 0, array($node));
                if ($node instanceof HaqXmlNodeElement)
                {
                    $n = array_search($beforeNode, $this->children, true);
                    if ($n!==false)
                    {
                        array_splice($this->children, $n, 0, array($node));
                    }
                }
            }
        }
    }

    function toString()
	{
		return $this->__toString();
	}
	
    function __toString()
    {
        $sAttrs = implode(' ',$this->attributes);
        if ($sAttrs!='') $sAttrs = ' '.$sAttrs;
        
        if (count($this->nodes)==0 && (
                array_key_exists($this->name, HaqXmlParser::getSelfClosingTags())
                ||
                strpos($this->name, ':')!==false
           )
        ) return "<$this->name$sAttrs />";

        $sChildren = implode('',$this->nodes);
        return $this->name!==null && $this->name!=='' 
            ? "<$this->name$sAttrs>$sChildren</$this->name>"
            : $sChildren;
    }

    public function serialize()
    {
        return serialize(array($this->name, $this->attributes, $this->nodes));
    }

    public function unserialize($serialized)
    {
        list ($this->name, $this->attributes, $nodes) = unserialize($serialized);
        $this->nodes = array();
        $this->children = array();
        foreach ($nodes as $node) $this->addChild($node);
    }

    function getAttribute($name)
    {
        $nameLowered = strtolower($name);
        $a = array_key_exists($nameLowered, $this->attributes) ? $this->attributes[$nameLowered] : null;
        return $a ? $a->value : null;
    }

    function setAttribute($name, $value)
    {
        $nameLowered = strtolower($name);
        if (array_key_exists($nameLowered, $this->attributes))
        {
            $this->attributes[$nameLowered]->value = $value;
        }
        else
        {
            $this->attributes[$nameLowered] = new HaqXmlAttribute($name, $value, '"');
        }
    }

    function removeAttribute($name)
    {
        unset($this->attributes[strtolower($name)]);
    }

    function hasAttribute($name)
    {
        return array_key_exists(strtolower($name), $this->attributes);
    }
    
    function __set($name, $value)
    {
        switch($name)
        {
            case 'innerHTML':
                $nodes = HaqXmlParser::parse($value);
                $this->nodes = array();
                $this->children = array();
                foreach ($nodes as $node) $this->addChild($node);
                break;
            default:
                throw new Exception("Property '$name' not defined.");
        }
    }
    
    function __get($name)
    {
        switch($name)
        {
            case 'innerHTML':
                return implode('',$this->nodes);
            default:
                throw new Exception("Property '$name' not defined.");
        }
    }
    
    function __isset($name)
    {
        switch($name)
        {
            case 'innerHTML': return true;
        }
        return false;
    }
    
    /**
     * @param string $selector
     * @return HaqXmlNodeElement[]
     */
    function find($selector)
    {
        $parsedSelectors = HaqXmlParser::parseCssSelector($selector);
        $resNodes = array();
        foreach ($parsedSelectors as $s)
        {
            foreach ($this->children as $node)
            {
                $nodesToAdd = $node->findInner($s);
                foreach ($nodesToAdd as $nodeToAdd)
                {
                    if (!in_array($nodeToAdd, $resNodes, true)) 
                    {
                        array_push($resNodes, $nodeToAdd);
                    }
                }
            }
        }
        return $resNodes;
    }
    
    private function findInner($selectors)
    {
        if (count($selectors)==0) return array();
        
        $nodes = array();
        if ($selectors[0]['type']==' ') 
        {
            foreach ($this->children as /*@var $child HaqXmlNodeElement*/$child) 
            {
                $nodes = array_merge($nodes, $child->findInner($selectors));
            }
        }
            
        if ($this->isSelectorTrue($selectors[0]))
        {
            if (count($selectors)==1)
            {
                if ($this->parent!==null) array_push($nodes, $this);
            }
            else
            {
                array_shift($selectors);
                foreach ($this->children as /*@var $child HaqXmlNodeElement*/$child) 
                {
                    $nodes = array_merge($nodes, $child->findInner($selectors));
                }                    
            }
        }
        
        return $nodes;
    }
    
    private function isSelectorTrue($selector)
    {
        foreach ($selector['tags'] as $tag) if (strcasecmp($this->name,$tag)!=0) return false;
        foreach ($selector['ids'] as $id) if ($this->getAttribute('id')!==$id) return false;
        foreach ($selector['classes'] as $class) 
            if (!preg_match('/(?:^|\s)'.preg_quote($class,'/').'(?:$|\s)/',$this->getAttribute('class'))) 
                    return false;
        return true;
    }
    
    function replaceChild(HaqXmlNode $node, HaqXmlNode $newNode)
    {
        $newNode = unserialize(serialize($newNode));
        $newNode->parent = $this;
        
        for ($i=0;$i<count($this->nodes);$i++)
        {
            if ($this->nodes[$i]===$node)
            {
                $this->nodes[$i] = $newNode;
                break;
            }
        }
        
        for ($i=0;$i<count($this->children);$i++)
        {
            if ($this->children[$i]===$node)
            {
                $this->children[$i] = $newNode;
                break;
            }
        }
    }
    
    /**
     * Заменяет элемент на дочерние узлы заданного элемента.
     * @param HaqXmlNode $node Элемент, который нужно заменить.
     * @param HaqXmlNodeElement $nodeContainer Элемент, содержащий дочерние узлы, которые попадут на место заменяемого.
     */
    function replaceChildWithInner(HaqXmlNode $node, HaqXmlNodeElement $nodeContainer)
    {
        $nodeContainer = unserialize(serialize($nodeContainer));
        
        foreach ($nodeContainer->nodes as $n) $n->parent = $this;
        
        for ($i=0;$i<count($this->nodes);$i++)
        {
            if ($this->nodes[$i]===$node)
            {
                array_splice($this->nodes, $i, 1, $nodeContainer->nodes);
                break;
            }
        }
        
        for ($i=0;$i<count($this->children);$i++)
        {
            if ($this->children[$i]===$node)
            {
                array_splice($this->children, $i, 1, $nodeContainer->children);
                break;
            }
        }
    }
    
    function removeChild(HaqXmlNode $node)
    {
        $n = array_search($node, $this->nodes, true);
        if ($n!==false) 
        {
            array_splice($this->nodes, $n, 1);
            $n = array_search($node, $this->children, true);
            if ($n!==false) array_splice($this->children, $n, 1);
        }
    }
    
    function getAttributesAssoc()
    {
        $attrs = array();
        foreach ($this->attributes as $attr)
        {
            $attrs[$attr->name] = $attr->value; 
        }
        return $attrs;
    }

    function setInnerText($text)
    {
        $this->nodes = array();
        $this->children = array();
        $this->addChild(new HaqXmlNodeText($text));
    }
}

class HaqXml extends HaqXmlNodeElement
{
    function __construct($str='')
    {
        parent::__construct('', array());
        $nodes = HaqXmlParser::parse($str);
        foreach ($nodes as $node) $this->addChild($node);
    }
}

class HaqXmlNodeText extends HaqXmlNode
{
    /**
     * @var string
     */
    public $text;

    function __construct($text)
    {
        $this->text = $text;
    }

    function toString()
    {
        return $this->__toString();
    }
    
	function __toString()
    {
        return $this->text;
    }

    public function serialize()
    {
        return serialize($this->text);
    }

    public function unserialize($serialized)
    {
        $this->text = unserialize($serialized);
    }
}

class HaqXmlAttribute
{
    public $name;
    public $value;
    public $quote;

    function __construct($name, $value, $quote)
    {
        $this->name = $name;
        $this->value = $value;
        $this->quote = $quote;
    }

    function toString()
    {
        return $this->__toString();
    }
    
	function __toString()
    {
        return "$this->name=$this->quote$this->value$this->quote";
    }
}

class HaqXmlParser
{
    public static function getSelfClosingTags() { return array('img'=>1, 'br'=>1, 'input'=>1, 'meta'=>1, 'link'=>1, 'hr'=>1, 'base'=>1, 'embed'=>1, 'spacer'=>1); }
    private static function getRegExpForID() { return '[a-z](?:-?[_a-z0-9])*'; }
    private static function getRegExpForAttr($isNamed)
    {
        $reID = self::getRegExpForID();
        return !$isNamed
            ? "$reID\s*=\s*(?:'[^']*'|\"[^\"]*\"|[-_a-z0-9]+)"
            : "(?<name>$reID)\s*=\s*(?<value>'[^']*'|\"[^\"]*\"|[-_a-z0-9]+)";

    }

    /**
     * @param $str string
     * @return HaqXmlNode[]
     */
    static function parse($str)
    {
        $reID = self::getRegExpForID();
        $reAttr = self::getRegExpForAttr(false);

        $reElementName = "$reID(?::$reID)?";
        $reAttr = "$reID\s*=\s*(?:'[^']*'|\"[^\"]*\"|[-_a-z0-9]+)";
        $reElementOpen = "<\s*(?<tagOpen>$reElementName)";
        $reElementEnd = "(?<tagEnd>/)?\s*>";
        $reElementClose = "<\s*/\s*(?<tagClose>$reElementName)\s*>";
        $reScript = "[<]\s*script\s*(?<scriptAttrs>[^>]*)>(?<scriptText>.*?)<\s*/\s*script\s*>";
        $reStyle = "<\s*style\s*(?<styleAttrs>[^>]*)>(?<styleText>.*?)<\s*/\s*style\s*>";
        $reComment = "<!--.*?-->";

        $re = "#(?<script>$reScript)|(?<style>$reStyle)|(?<elem>$reElementOpen(?<attrs>(?:\s+$reAttr)*)\s*$reElementEnd)|(?<close>$reElementClose)|(?<comment>$reComment)#is";

        if (preg_match_all($re, $str, $matches, PREG_SET_ORDER | PREG_OFFSET_CAPTURE))
        {
            $i = 0;
            $nodes = self::parseInner($str, $matches, $i);
            if ($i<count($matches)) throw new Exception("Error parsing XML:\n<br>".$str);
            return $nodes;
        }
        return strlen($str) > 0 ? array(new HaqXmlNodeText($str)) : array();
    }

    private static function parseInner($str, $matches, &$i)
    {
        $nodes = array();

        $prevEnd = $i>0 ? $matches[$i-1][0][1]+strlen($matches[$i-1][0][0]) : 0;
        $curStart = $matches[$i][0][1];
        if ($prevEnd<$curStart)
        {
            array_push($nodes, new HaqXmlNodeText(substr($str, $prevEnd, $curStart-$prevEnd)));
        }

        for (; $i<count($matches); $i++)
        {
            $m = $matches[$i];
            if (isset($m['elem']) && $m['elem'][0]!='')
            {
                array_push($nodes, self::parseElement($str, $matches, $i));
            }
            else
            if (isset($m['script']) && $m['script'][0]!='')
            {
                $scriptNode = new HaqXmlNodeElement('script', self::parseAttrs($m['scriptAttrs'][0]));
                $scriptNode->addChild(new HaqXmlNodeText($m['scriptText'][0]));
                array_push($nodes, $scriptNode);
            }
            else
            if (isset($m['style']) && $m['style'][0]!='')
            {
                $styleNode = new HaqXmlNodeElement('style', self::parseAttrs($m['styleAttrs'][0]));
                $styleNode->addChild(new HaqXmlNodeText($m['styleText'][0]));
                array_push($nodes, $styleNode);
            }
            else
            if (isset($m['close']) && $m['close'][0]!='') break;
            else
            if (isset($m['comment']) && $m['comment'][0] != '')
            {
                array_push($nodes, new HaqXmlNodeText($m['comment'][0]));
            }
            else
            {
                throw new Exception();
            }

            $curEnd = $matches[$i][0][1]+strlen($matches[$i][0][0]);
            $nextStart = $i+1<count($matches) ? $matches[$i+1][0][1] : strlen($str);
            if ($curEnd < $nextStart)
            {
                array_push($nodes, new HaqXmlNodeText(substr($str, $curEnd, $nextStart-$curEnd)));
            }
        }
        return $nodes;
    }

    private static function parseElement($str, $matches, &$i)
    {
        $tag = $matches[$i]['tagOpen'][0];
        $attrs = $matches[$i]['attrs'][0];
        $isWithClose = isset($matches[$i]['tagEnd']) || array_key_exists($tag, self::getSelfClosingTags());

        $elem = new HaqXmlNodeElement($tag, self::parseAttrs($attrs));
        if (!$isWithClose)
        {
            $i++;
            $nodes = self::parseInner($str, $matches, $i);
            foreach ($nodes as $node) $elem->addChild($node);
            if ($matches[$i]['close'][0]=='' || $matches[$i]['tagClose'][0]!=$tag)
                throw new Exception ("XML parse error: tag <$tag> not closed. ParsedText = \n<pre>".$str."</pre>\n");
        }

        return $elem;
    }

    /**
     * @param string $str
     * @return HaqXmlAttribute[]
     */
    private static function parseAttrs($str)
    {
        $attributes = array();

        if (preg_match_all("#".self::getRegExpForAttr(true)."#is", $str, $matches, PREG_SET_ORDER))
        {
            for ($i = 0; $i < count($matches); $i++)
            {
                $name = $matches[$i]['name'];
                $value = $matches[$i]['value'];
                $quote = substr($value,0,1);
                if ($quote=='"' || $quote=="'") $value = substr($value,1,strlen($value)-2);
                else                            $quote = '';
                $attributes[strtolower($name)] = new HaqXmlAttribute($name, $value, $quote);
            }
        }

        return $attributes;
    }
    
    static function parseCssSelector($selector)
    {
        $selectors = preg_split('/\s*,\s*/', $selector, 0, PREG_SPLIT_NO_EMPTY);
        $r = array();
        foreach ($selectors as $s)
        {
            array_push($r, self::parseCssSelectorInner($s));
        }
        return $r;
    }
    
    private static function parseCssSelectorInner($selector)
    {
        $reSubSelector = '[.#]?'.self::getRegExpForID().'(?::'.self::getRegExpForID().')?';
        
        $parsedSelectors = array();
        if (preg_match_all("/(?<type>[ >])(?<selector>(?:$reSubSelector)+|[*])/is", ' '.$selector, $mSubSelectors, PREG_SET_ORDER))
        {
            foreach ($mSubSelectors as $mSubSelector)
            {
                $tags = array();
                $ids = array();
                $classes = array();
                if ($mSubSelector['selector']!='*')
                {
                    if (preg_match_all("/$reSubSelector/is", $mSubSelector['selector'], $m, PREG_SET_ORDER))
                    {
                        for ($i=0; $i<count($m); $i++)
                        {
                            $s = $m[$i][0];
                            if      (substr($s,0,1)=="#") array_push($ids, substr($s,1));
                            else if (substr($s,0,1)==".") array_push($classes, substr($s,1));
                            else                          array_push($tags, strtolower ($s));
                        }
                    }
                }
                array_push($parsedSelectors, array(
                    'type'=>$mSubSelector['type'], 
                    'tags'=>$tags, 
                    'ids'=>$ids, 
                    'classes'=>$classes
                ));
            }
        }
        return $parsedSelectors;
    }
}
