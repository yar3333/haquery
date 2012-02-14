package tests;

import haquery.server.HaqComponentCollection;
import haxe.unit.TestCase;
import php.FileSystem;
import haquery.server.HaqComponent;
import haquery.server.HaqComponentManager;
import haquery.server.Lib;
import haquery.server.HaqDefines;

using haquery.StringTools;

class HaqTemplatesTest extends TestCase
{
	public function testEmpty()
	{
		var collection = new HaqComponentCollection('');
		var manager = new HaqComponentManager(collection);
	}
	
	public function testComponentsSet0()
	{
		var collection = new HaqComponentCollection('set0');
		var template = collection.getTemplate(null, 'text');
		assertTrue(template != null);
		
		if (template != null)
		{
			assertEquals("text component template file", template.doc.innerHTML);
			assertEquals("", template.css);
			assertEquals("components/set0/text/support/suptest.txt", template.getSupportFilePath("suptest.txt"));
		}
	}
	
	public function testComponentsSet1()
	{
		/*var dataFilePath = HaqDefines.folders.temp + '/components1/components.data';
		if (FileSystem.exists(dataFilePath)) FileSystem.deleteFile(dataFilePath);
		var stylesFilePath = HaqDefines.folders.temp + '/components1/styles.css';
		if (FileSystem.exists(stylesFilePath)) FileSystem.deleteFile(stylesFilePath);*/
		
		var collection = new HaqComponentCollection('set1');
		var template = collection.getTemplate(null, 'randnum');
		assertTrue(template != null);
		
		var html = template.doc.innerHTML;
        assertEquals(StringTools.htmlEscape("<div id='n'>0</div>"), StringTools.htmlEscape(html.trim(' \t\r\n')));
		//assertEquals(template.serverHandlers.keys().hasNext(), false);
	}
	
	public function testComponentsSet1CreateRandNum()
	{
		var collection = new HaqComponentCollection('set1');
        var template = collection.getTemplate(null, 'randnum');
		assertTrue(template != null);
        assertEquals('components.set1.randnum.Server', Type.getClassName(template.serverClass));
		
		var manager = new HaqComponentManager(collection);
		
		var randnum : HaqComponent = manager.createComponent(null, 'randnum', 'rn', null, null);
		assertTrue(randnum != null);
		assertEquals('components.set1.randnum.Server', Type.getClassName(Type.getClass(randnum)));
		
		randnum.forEachComponent('preRender');
		var html = randnum.render();
		assertEquals(StringTools.htmlEscape("<div id='rn-n'>123</div>"), StringTools.htmlEscape(html.trim(' \t\r\n')));
	}
}