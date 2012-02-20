#if php
package tests;

import php.Lib;
import php.NativeArray;
import php.NativeString;
import haquery.server.HaqXml;
import haquery.server.HaqQuery;

class HaqQueryTest extends haxe.unit.TestCase
{
	public function testGetAttr()
    {
		var doc : HaqXml = new HaqXml('<a href="url">привет</a>');
		var query = new HaqQuery('', '', 'a', doc.find('a'));
		assertEquals('url', query.attr('href'));
    }
	
	public function testSetAttr()
    {
		var doc : HaqXml = new HaqXml('<a href="url">привет</a>');
		var query = new HaqQuery('', '', 'a', doc.find('a'));
		query.attr('href', 'newurl');
		assertEquals('newurl', query.attr('href'));
    }
	
	public function testGetHtml()
    {
		var doc : HaqXml = new HaqXml('<a href="url">привет</a>');
		var query = new HaqQuery('', '', 'a', doc.find('a'));
		assertEquals('привет', query.html());
    }
	
	public function testSetHtml()
    {
		var doc : HaqXml = new HaqXml('<a href="url">привет</a>');
		var query = new HaqQuery('', '', 'a', doc.find('a'));
		query.html('до свидания');
		assertEquals('до свидания', query.html());
    }
	
	public function testGetVal()
    {
		var doc : HaqXml = new HaqXml('<input type="text" value="abc" />');
		var query = new HaqQuery('', '', 'input', doc.find('input'));
		assertEquals('abc', query.val());
    }
	
	public function testSetVal()
    {
		var doc : HaqXml = new HaqXml('<input type="text" value="abc" />');
		var query = new HaqQuery('', '', 'input', doc.find('input'));
		query.val('def');
		assertEquals('def', query.val());
    }
}

#end