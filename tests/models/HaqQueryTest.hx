package models;

import php.Lib;
import php.NativeArray;
import php.NativeString;
import haxe.htmlparser.HtmlParser;
import haquery.server.HaqQuery;
import haquery.server.HaqCssGlobalizer;

class HaqQueryTest extends haxe.unit.TestCase
{
	public function testGetAttr()
    {
		var doc : HtmlDocument = new HtmlDocument('<a href="url">привет</a>');
		var query = new HaqQuery(new HaqCssGlobalizer(''), '', 'a', doc.find('a'));
		assertEquals('url', query.attr('href'));
    }
	
	public function testSetAttr()
    {
		var doc : HtmlDocument = new HtmlDocument('<a href="url">привет</a>');
		var query = new HaqQuery(new HaqCssGlobalizer(''), '', 'a', doc.find('a'));
		query.attr('href', 'newurl');
		assertEquals('newurl', query.attr('href'));
    }
	
	public function testGetHtml()
    {
		var doc : HtmlDocument = new HtmlDocument('<a href="url">привет</a>');
		var query = new HaqQuery(new HaqCssGlobalizer(''), '', 'a', doc.find('a'));
		assertEquals('привет', query.html());
    }
	
	public function testSetHtml()
    {
		var doc : HtmlDocument = new HtmlDocument('<a href="url">привет</a>');
		var query = new HaqQuery(new HaqCssGlobalizer(''), '', 'a', doc.find('a'));
		query.html('до свидания');
		assertEquals('до свидания', query.html());
    }
	
	public function testGetVal()
    {
		var doc : HtmlDocument = new HtmlDocument('<input type="text" value="abc" />');
		var query = new HaqQuery(new HaqCssGlobalizer(''), '', 'input', doc.find('input'));
		assertEquals('abc', query.val());
    }
	
	public function testSetVal()
    {
		var doc : HtmlDocument = new HtmlDocument('<input type="text" value="abc" />');
		var query = new HaqQuery(new HaqCssGlobalizer(''), '', 'input', doc.find('input'));
		query.val('def');
		assertEquals('def', query.val());
    }
}
