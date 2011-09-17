package tests;

import haxe.unit.TestCase;
import php.FileSystem;
import php.Lib;
import haquery.server.HaqComponent;
import haquery.server.HaqComponentManager;
import haquery.server.HaqTemplates;
import haquery.server.HaQuery;
using haquery.StringTools;

class HaqTemplatesTest extends TestCase
{
	override public function setup()
	{
	}
	
	public function testEmpty()
	{
		var templates = new HaqTemplates([]);
		assertTrue(templates != null);
	}
	
	public function testComponents0()
	{
		//Lib.println('\n===> new HaqTemplates(HaQuery.config.componentsFolders)');
		var templates = new HaqTemplates([ 'components0' ]);
		
		var tags = templates.getTags();
		this.assertEquals(1, tags.length);
		this.assertEquals('text', tags[0]);
	}
	
	public function testComponents1()
	{
		var dataFilePath = HaQuery.folders.temp + '/components1/components.data';
		if (FileSystem.exists(dataFilePath)) FileSystem.deleteFile(dataFilePath);
		var stylesFilePath = HaQuery.folders.temp + '/components1/styles.css';
		if (FileSystem.exists(stylesFilePath)) FileSystem.deleteFile(stylesFilePath);
		
		var templates = new HaqTemplates([ 'components1' ]);
		
		var tags = templates.getTags();
		this.assertEquals(1, tags.length);
		this.assertEquals('randnum', tags[0]);
		
		var template = templates.get('randnum');
		assertEquals(StringTools.htmlEscape("<div id='n'>0</div>"), StringTools.htmlEscape(template.doc.innerHTML.trim(' \t\r\n')));
		assertEquals(template.serverHandlers.keys().hasNext(), false);
	}
	
	public function testComponents1CreateRandNum()
	{
		var templates = new HaqTemplates([ 'components1' ]);
        assertTrue(templates.get('randnum') != null);
        assertEquals('components1.randnum.Server', Type.getClassName(templates.get('randnum').serverClass));
		
        var manager : HaqComponentManager = new HaqComponentManager(templates);
		var randnum : HaqComponent = manager.createComponent(null, 'randnum', 'rn', null, '');
		assertTrue(randnum != null);
		assertEquals('components1.randnum.Server', Type.getClassName(Type.getClass(randnum)));
		
		randnum.forEachComponent('preRender');
		var html = randnum.render();
		assertEquals(StringTools.htmlEscape("<div id='rn-n'>123</div>"), StringTools.htmlEscape(html));
	}
}