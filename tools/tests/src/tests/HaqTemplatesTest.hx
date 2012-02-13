package tests;

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
		var manager = new HaqComponentManager([]);
		assertTrue(manager != null);
	}
	
	public function testComponentsSet0()
	{
		var manager = new HaqComponentManager([ 'set0' ]);
		var template = manager.getTemplate('text');
		assertTrue(template != null);
		if (template != null)
		{
			//template.
			
		}
	}
	
	public function testComponentsSet1()
	{
		var dataFilePath = HaqDefines.folders.temp + '/components1/components.data';
		if (FileSystem.exists(dataFilePath)) FileSystem.deleteFile(dataFilePath);
		var stylesFilePath = HaqDefines.folders.temp + '/components1/styles.css';
		if (FileSystem.exists(stylesFilePath)) FileSystem.deleteFile(stylesFilePath);
		
		var manager = new HaqComponentManager([ 'set1' ]);
		
		var template = manager.getTemplate('randnum');
		assertTrue(template != null);
		
		var html : String = template.doc.innerHTML;
        assertEquals(StringTools.htmlEscape("<div id='n'>0</div>"), StringTools.htmlEscape(html.trim(' \t\r\n')));
		assertEquals(template.serverHandlers.keys().hasNext(), false);
	}
	
	public function testComponentsSet1CreateRandNum()
	{
		var manager = new HaqComponentManager([ 'set1' ]);
        assertTrue(manager.getTemplate('randnum') != null);
        assertEquals('components1.randnum.Server', Type.getClassName(manager.getTemplate('randnum').serverClass));
		
		var randnum : HaqComponent = manager.createComponent(null, 'randnum', 'rn', null, null);
		assertTrue(randnum != null);
		assertEquals('components1.randnum.Server', Type.getClassName(Type.getClass(randnum)));
		
		randnum.forEachComponent('preRender');
		var html : String = randnum.render();
		assertEquals(StringTools.htmlEscape("<div id='rn-n'>123</div>"), StringTools.htmlEscape(html.trim(' \t\r\n')));
	}
}