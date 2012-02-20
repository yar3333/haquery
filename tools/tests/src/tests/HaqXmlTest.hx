package tests;

import haquery.server.HaqQuery;
import haxe.Serializer;
import php.Lib;
import php.NativeArray;
import php.NativeString;
import haquery.server.HaqXml;

class HaqXmlTest extends haxe.unit.TestCase
{
    public function testText()
    {
		var nodes = HaqXmlParser.parse("abc");
        this.assertEquals(1, nodes.length);

        var node = nodes[0];
		this.assertTrue(Type.getClass(node) == HaqXmlNodeText);
        this.assertEquals('abc', cast(node, HaqXmlNodeText).text);
    }

    public function testTagWithClose()
    {
		var nodes = HaqXmlParser.parse("<br p=2 />");
        this.assertEquals(1, nodes.length);

		this.assertTrue(Type.getClass(nodes[0]) == HaqXmlNodeElement);
        
		var node : HaqXmlNodeElement = cast nodes[0];
        this.assertEquals('br', node.name);
		
		this.assertEquals("String", Type.getClassName(Type.getClass("abc")));
		this.assertEquals(haquery.server.HaqQuery, Type.getClass(new HaqQuery("", "", "", cast nodes)));
    }

    public function testTagAndText()
    {
        var nodes = HaqXmlParser.parse("<a>abc</a>");
        this.assertEquals(1, nodes.length);

		this.assertTrue(Type.getClass(nodes[0]) == HaqXmlNodeElement);
		
        var node : HaqXmlNodeElement = cast nodes[0];
        this.assertEquals('a', node.name);
    }

    public function getParsedAsString(str:String) : String
    {
        var nodes = HaqXmlParser.parse(str);
        return Lambda.fold(nodes, function(node, s) return s + node.toString(), "");
    }

    public function testSimpleConvertDeconvert()
    {
        this.assertEquals("<a>abc</a>", this.getParsedAsString("<a>abc</a>"));
        this.assertEquals("<a p=2>abc</a>", this.getParsedAsString("<a p=2>abc</a>"));
        this.assertEquals("<a p=2>abc</a>", this.getParsedAsString("<a p = 2>abc</a>"));
        this.assertEquals("<a p='2'>abc</a>", this.getParsedAsString("<a p = '2'>abc</a>"));
        this.assertEquals('<a p="2">abc</a>', this.getParsedAsString('<a p = "2">abc</a>'));
        this.assertEquals('<br />', this.getParsedAsString('<br/>'));
        this.assertEquals('<br />', this.getParsedAsString('<br />'));
        this.assertEquals("<a href='http://ya.ru?a=5'>Все на Яндекс!</a>", this.getParsedAsString("<a href='http://ya.ru?a=5'>Все на Яндекс!</a>"));
    }

    public function testComplexConvertDeconvert()
    {
        this.assertEquals(this.getParsedAsString("<p><a>abc</a></p>"), "<p><a>abc</a></p>");
    }

    public function testManyRootNodes()
    {
        this.assertEquals(this.getParsedAsString("<p>abc</p>TEXT<a>def</a>"), "<p>abc</p>TEXT<a>def</a>");
    }

    public function testComment()
    {
        var nodes = HaqXmlParser.parse("<a><!-- comment<p></p> --></a>");
        this.assertEquals(1, nodes.length);
        this.assertTrue(Type.getClass(nodes[0]) == HaqXmlNodeElement);
        
        var node : HaqXmlNodeElement = cast nodes[0];
        var subnodes = node.nodes;
        this.assertEquals(1, subnodes.length);
        this.assertTrue(Type.getClass(subnodes[0]) == HaqXmlNodeText);
    }
    
    public function testComplexParse()
    {
		var s = php.io.File.getContent('tests/HaqXmlTest-in.html');
		php.io.File.putContent("tests/HaqXmlTest-out.html", this.getParsedAsString(s));
		assertEquals(s, php.io.File.getContent('tests/HaqXmlTest-out.html'));
    }
    
	public function processSerializationTest(str:String)
    {
		var doc = new HaqXml(str);
		var dstDoc : Array<HaqXmlNodeElement> = cast haxe.Unserializer.run(doc.serialize());
		this.assertEquals(str, doc.innerHTML);
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
    
    public function testSelectors()
    {
        var xml = new HaqXml("<div class='first second'><p id='myp' class='first'><a href='b'>cde</a></p></div>");
        
        var nodes = xml.find('');
        this.assertEquals(0, nodes.length);
        
        var nodes = xml.find('div');
        this.assertEquals(1, nodes.length);
        
        var divs = xml.find('div');
        nodes = divs[0].find('div');
        this.assertEquals(0, nodes.length);
        
        nodes = divs[0].find('*');
        this.assertEquals(2, nodes.length);
        
        nodes = xml.find('#no');
        this.assertEquals(0, nodes.length);

        nodes = xml.find('.no');
        this.assertEquals(0, nodes.length);
        
        nodes = xml.find('a');
        this.assertEquals(1, nodes.length);
        this.assertEquals('a', nodes[0].name);
        this.assertEquals('b', nodes[0].getAttribute('href'));
        
        nodes = xml.find('.first');
        this.assertEquals(2, nodes.length);
        this.assertEquals('p', nodes[0].name);
        this.assertEquals('div', nodes[1].name);
        
        nodes = xml.find('.first.second');
        this.assertEquals(1, nodes.length);
        this.assertEquals('div', nodes[0].name);
        
        nodes = xml.find('#myp');
        this.assertEquals(1, nodes.length);
        this.assertEquals('p', nodes[0].name);
        
        nodes = xml.find('.first#myp');
        this.assertEquals(1, nodes.length);
        
        nodes = xml.find('.second#myp');
        this.assertEquals(0, nodes.length);
        
        nodes = xml.find('.first.second a');
        this.assertEquals(1, nodes.length);
        
        nodes = xml.find('.first.second>a');
        this.assertEquals(0, nodes.length);
        
        nodes = xml.find('.first.second >a');
        this.assertEquals(0, nodes.length);
        
        nodes = xml.find('.second>a');
        this.assertEquals(0, nodes.length);
        
        nodes = xml.find('.second a');
        this.assertEquals(1, nodes.length);
        
        nodes = xml.find('.first>a');
        this.assertEquals(1, nodes.length);
        
        nodes = xml.find('div>p>a');
        this.assertEquals(1, nodes.length);
        
        nodes = xml.find('div>a');
        this.assertEquals(0, nodes.length);
        
        nodes = xml.find('div>*>a');
        this.assertEquals(1, nodes.length);
        
        nodes = xml.find('*');
        this.assertEquals(3, nodes.length);
        
        nodes = xml.find('a,p');
        this.assertEquals(2, nodes.length);
        
        nodes = xml.find('a , p');
        this.assertEquals(2, nodes.length);
        
        nodes = xml.find('a, a');
        this.assertEquals(1, nodes.length);
    }

    public function testSiblings()
    {
        var xml = new HaqXml("<br />\n        <div id='m'>test</div>");
        var nodes = xml.find("#m");
		
        this.assertEquals(1, nodes.length);
		this.assertTrue(Type.getClass(nodes[0]) == HaqXmlNodeElement);
        
		var node : HaqXmlNodeElement = nodes[0];
        this.assertEquals("m", node.getAttribute('id'));
        
		var prev = node.getPrevSiblingNode();
		this.assertTrue(Type.getClass(prev) == HaqXmlNodeText);
        this.assertEquals("\n        ", cast(prev, HaqXmlNodeText).text);
    }
	
	public function testStyle()
	{
		var html = "
<style>
    .randnum
    {
        color: blue;
    }
</style>

<div id='n'>0</div>
";

		var xml = new HaqXml(html);
		assertEquals(2, xml.children.length);
        
		var nodes = xml.find("#n");
        assertEquals(1, nodes.length);
		assertTrue(Type.getClass(nodes[0]) == HaqXmlNodeElement);
	}
	
	public function testReplaceChildWithInner()
	{
		var xml = new HaqXml("b<ph>c</ph>d<con>e</con>");
		
		var nodesPH = xml.find("ph");
		assertEquals(1, nodesPH.length);
		assertEquals(0, nodesPH[0].children.length);
		
		var nodesCON = xml.find("con");
		assertEquals(1, nodesCON.length);
		assertEquals(0, nodesCON[0].children.length);
		
		xml.replaceChildWithInner(nodesPH[0], nodesCON[0]);
		assertEquals("bed<con>e</con>", xml.innerHTML);
		assertEquals(1, xml.children.length);
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
}
