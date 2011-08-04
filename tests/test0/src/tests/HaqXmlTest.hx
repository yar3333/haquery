#if php
package tests;

import php.Lib;
import php.NativeArray;
import php.NativeString;
import haquery.server.HaqXml;

class HaqXmlTest extends haxe.unit.TestCase
{
    public function testText()
    {
		var nodes = Lib.toHaxeArray(HaqXmlParser.parse("abc"));
        this.assertEquals(1, nodes.length);

        var node = nodes[0];
        //this.assertInstanceOf("HaqXmlNodeText", node);
        this.assertEquals('abc', cast(node, HaqXmlNodeText).text);
    }

    public function testTagWithClose()
    {
        var nodes = Lib.toHaxeArray(HaqXmlParser.parse("<br p=2 />"));
        //this.assertInternalType("array", nodes);
        this.assertEquals(1, nodes.length);

        /* @var $node HaqXmlNodeElement */
        var node = nodes[0];
        //this.assertInstanceOf("HaqXmlNodeElement", node);
        this.assertEquals('br', cast(node, HaqXmlNodeElement).name);
    }

    public function testTagAndText()
    {
        var nodes = Lib.toHaxeArray(HaqXmlParser.parse("<a>abc</a>"));
        //this.assertInternalType("array", nodes);
        this.assertEquals(1, nodes.length);

        /* @var $node HaqXmlNodeElement */
        var node = nodes[0];
        //this.assertInstanceOf("HaqXmlNodeElement", node);
        this.assertEquals('a', cast(node, HaqXmlNodeElement).name);
    }

    public function getParsedAsString(str:String)
    {
        var nodes : Array<Dynamic> = Lib.toHaxeArray(HaqXmlParser.parse(str));
        return nodes.join('');
    }

    public function testSimpleConvertDeconvert()
    {
        this.assertEquals(this.getParsedAsString("<a>abc</a>"), "<a>abc</a>");
        this.assertEquals(this.getParsedAsString("<a p=2>abc</a>"), "<a p=2>abc</a>");
        this.assertEquals(this.getParsedAsString("<a p = 2>abc</a>"), "<a p=2>abc</a>");
        this.assertEquals(this.getParsedAsString("<a p = '2'>abc</a>"), "<a p='2'>abc</a>");
        this.assertEquals(this.getParsedAsString('<a p = "2">abc</a>'), '<a p="2">abc</a>');
        this.assertEquals(this.getParsedAsString('<br/>'), '<br />');
        this.assertEquals(this.getParsedAsString('<br />'), '<br />');
        this.assertEquals(this.getParsedAsString("<a href='http://ya.ru?a=5'>Все на Яндекс!</a>"), "<a href='http://ya.ru?a=5'>Все на Яндекс!</a>");
    }

    public function testComplexConvertDeconvert()
    {
        this.assertEquals(this.getParsedAsString("<p><a>abc</a></p>"), "<p><a>abc</a></p>");
    }

    public function testManyRootNodes()
    {
        this.assertEquals(this.getParsedAsString("<p>abc</p>TEXT<a>def</a>"), "<p>abc</p>TEXT<a>def</a>");
    }

    public function testComplexParse()
    {
        var s = php.io.File.getContent('tests/HaqXmlTest-in.html');
		php.io.File.putContent("tests/HaqXmlTest-out.html", this.getParsedAsString(s));
		assertEquals(s, php.io.File.getContent('tests/HaqXmlTest-out.html'));
    }

    public function processSerializationTest(str:String)
    {
		var srcNodesNative = HaqXmlParser.parse(str);
		var srcNodes = Lib.toHaxeArray(srcNodesNative);
        var srcNodesStr = srcNodes.join('');
        
		var s: String = php.Lib.serialize(srcNodesNative);
		var r: Dynamic = php.Lib.unserialize(s);
		
		//untyped __php__("var_dump($r);");
		
		var dstNodes = Lib.toHaxeArray(cast(r, NativeArray));
		var dstNodesStr = dstNodes.join('');
        
		this.assertEquals(dstNodesStr, srcNodesStr);
    }


    public function testSerialization1()
    {
        this.processSerializationTest("abc");
    }
    public function testSerialization2()
    {
        this.processSerializationTest("<p><a>abc</a><br /></p>");
    }
    public function testSerialization3()
    {
        this.processSerializationTest(php.io.File.getContent('tests/HaqXmlTest-in.html'));
    }
    
    /*public function testSpeed()
    {
        str = php.io.File.getContent('xmlTest-in.html');
        loops = 200;
        
        start = microtime(true);
        for (i = 0; i < loops; i++)
        {
            xml = new haquery_models_HaqXml(str);
        }
        echo "\nspeed: "+((microtime(true)-start)/loops);
        
        xml = new haquery_models_HaqXml(str);
        saved = php.Lib.serialize(xml);
        start = microtime(true);
        for (i = 0; i < loops; i++)
        {
            xml = php.Lib.unserialize(saved);
        }
        echo "\nspeed (unserialize): "+((microtime(true)-start)/loops);

        echo "\n";
    }*/
    
    public function testSelectors()
    {
        var xml = new HaqXml("<div class='first second'><p id='myp' class='first'><a href='b'>cde</a></p></div>");
        
        var nodes = Lib.toHaxeArray(xml.find(''));
        //this.assertInternalType('array', nodes);
        this.assertEquals(0, nodes.length);
        
        var nodes = Lib.toHaxeArray(xml.find('div'));
        //this.assertInternalType('array', nodes);
        this.assertEquals(1, nodes.length);
        
        var divs = Lib.toHaxeArray(xml.find('div'));
        nodes = Lib.toHaxeArray(divs[0].find('div'));
        //this.assertInternalType('array', nodes);
        this.assertEquals(0, nodes.length);
        
        nodes = Lib.toHaxeArray(divs[0].find('*'));
        //echo "DIVS = "+((string)divs[0])+"\n";
        //this.assertInternalType('array', nodes);
        this.assertEquals(2, nodes.length);
        
        nodes = Lib.toHaxeArray(xml.find('#no'));
        this.assertEquals(0, nodes.length);

        nodes = Lib.toHaxeArray(xml.find('.no'));
        this.assertEquals(0, nodes.length);
        
        nodes = Lib.toHaxeArray(xml.find('a'));
        //this.assertInternalType('array', nodes);
        this.assertEquals(1, nodes.length);
        this.assertEquals('a', nodes[0].name);
        this.assertEquals('b', nodes[0].getAttribute('href'));
        
        nodes = Lib.toHaxeArray(xml.find('.first'));
        this.assertEquals(2, nodes.length);
        this.assertEquals('p', nodes[0].name);
        this.assertEquals('div', nodes[1].name);
        
        nodes = Lib.toHaxeArray(xml.find('.first.second'));
        this.assertEquals(1, nodes.length);
        this.assertEquals('div', nodes[0].name);
        
        nodes = Lib.toHaxeArray(xml.find('#myp'));
        this.assertEquals(1, nodes.length);
        this.assertEquals('p', nodes[0].name);
        
        nodes = Lib.toHaxeArray(xml.find('.first#myp'));
        this.assertEquals(1, nodes.length);
        
        nodes = Lib.toHaxeArray(xml.find('.second#myp'));
        this.assertEquals(0, nodes.length);
        
        nodes = Lib.toHaxeArray(xml.find('.first.second a'));
        this.assertEquals(1, nodes.length);
        
        nodes = Lib.toHaxeArray(xml.find('.first.second>a'));
        this.assertEquals(0, nodes.length);
        
        nodes = Lib.toHaxeArray(xml.find('.first.second >a'));
        this.assertEquals(0, nodes.length);
        
        nodes = Lib.toHaxeArray(xml.find('.second>a'));
        this.assertEquals(0, nodes.length);
        
        nodes = Lib.toHaxeArray(xml.find('.second a'));
        this.assertEquals(1, nodes.length);
        
        nodes = Lib.toHaxeArray(xml.find('.first>a'));
        this.assertEquals(1, nodes.length);
        
        nodes = Lib.toHaxeArray(xml.find('div>p>a'));
        this.assertEquals(1, nodes.length);
        
        nodes = Lib.toHaxeArray(xml.find('div>a'));
        this.assertEquals(0, nodes.length);
        
        nodes = Lib.toHaxeArray(xml.find('div>*>a'));
        this.assertEquals(1, nodes.length);
        
        nodes = Lib.toHaxeArray(xml.find('*'));
        this.assertEquals(3, nodes.length);
        
        nodes = Lib.toHaxeArray(xml.find('a,p'));
        this.assertEquals(2, nodes.length);
        
        nodes = Lib.toHaxeArray(xml.find('a , p'));
        this.assertEquals(2, nodes.length);
        
        nodes = Lib.toHaxeArray(xml.find('a, a'));
        this.assertEquals(1, nodes.length);
    }

    public function testSiblings()
    {
        var xml = new HaqXml("<br />\n        <div id='m'>test</div>");
        var nodes = Lib.toHaxeArray(xml.find("#m"));
        //this.assertInternalType('array', nodes);
        this.assertEquals(1, nodes.length);
        var node = nodes[0];
        //this.assertInstanceOf("HaqXmlNodeElement", node);
        this.assertEquals("m", node.getAttribute('id'));
        var prev = node.getPrevSiblingNode();
        //this.assertInstanceOf("HaqXmlNodeText", prev);
        this.assertEquals("\n        ", cast(prev, HaqXmlNodeText).text);
    }	
	
}
#end