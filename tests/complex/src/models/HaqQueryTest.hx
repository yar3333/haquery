package models;

import htmlparser.HtmlDocument;
import haquery.server.HaqQuery;
import haquery.server.HaqCssGlobalizer;

class HaqQueryTest extends haxe.unit.TestCase
{
	public function testGetAttr()
    {
		//var doc = new HtmlDocument('<a href="url">привет</a>');
		//var query = new HaqQuery(new HaqCssGlobalizer(''), '', 'a', doc.find('a'));
		//assertEquals('url', query.attr('href'));
    }
	/*
	public function testSetAttr()
    {
		var doc = new HtmlDocument('<a href="url">привет</a>');
		var query = new HaqQuery(new HaqCssGlobalizer(''), '', 'a', doc.find('a'));
		query.attr('href', 'newurl');
		assertEquals('newurl', query.attr('href'));
    }
	
	public function testGetHtml()
    {
		var doc = new HtmlDocument('<a href="url">привет</a>');
		var query = new HaqQuery(new HaqCssGlobalizer(''), '', 'a', doc.find('a'));
		assertEquals('привет', query.html());
    }
	
	public function testSetHtml()
    {
		var doc = new HtmlDocument('<a href="url">привет</a>');
		var query = new HaqQuery(new HaqCssGlobalizer(''), '', 'a', doc.find('a'));
		query.html('до свидания');
		assertEquals('до свидания', query.html());
    }
	
	public function testGetVal()
    {
		var doc = new HtmlDocument('<input type="text" value="abc" />');
		var query = new HaqQuery(new HaqCssGlobalizer(''), '', 'input', doc.find('input'));
		assertEquals('abc', query.val());
    }
	
	public function testSetVal()
    {
		var doc = new HtmlDocument('<input type="text" value="abc" />');
		var query = new HaqQuery(new HaqCssGlobalizer(''), '', 'input', doc.find('input'));
		query.val('def');
		assertEquals('def', query.val());
    }*/
}
