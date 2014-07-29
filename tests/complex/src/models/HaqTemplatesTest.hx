package models;

import haxe.unit.TestCase;
import stdlib.Profiler;
import sys.FileSystem;
import haquery.server.HaqComponent;
import haquery.server.HaqTemplateManager;
import haquery.server.Lib;
import haquery.common.HaqDefines;
import haquery.server.HaqConfig;
using stdlib.StringTools;

class HaqTemplatesTest extends TestCase
{
	/*public function testEmpty()
	{
		var manager = new HaqTemplateManager();
		assertTrue(manager != null);
	}
	
	public function testComponentsSet0()
	{
		var manager = new HaqTemplateManager();
		assertTrue(manager != null);
		
		var page = manager.createPage("pages.test0", null);
		assertTrue(page != null);
		
		var template = manager.get("test0.text");
		assertTrue(template != null);

		assertEquals("text component template file", template.getDocCopy().innerHTML);
		assertEquals("components/set0/text/support/suptest.txt", template.getSupportFilePath("suptest.txt"));
	}
	
	public function testComponentsSet1()
	{
		var manager = new HaqTemplateManager();
		assertTrue(manager != null);
		
		var page = manager.createPage("pages.test1", null);
		assertTrue(page != null);
		
		var template = manager.get("components.set1.randnum");
		assertTrue(template != null);
		
		var html = template.getDocCopy().innerHTML;
        assertEquals(StringTools.htmlEscape("<div id='n'>0</div>"), StringTools.htmlEscape(html.trim(" \t\r\n")));
	}
	
	public function testComponentsSet1CreateRandNum()
	{
		var manager = new HaqTemplateManager();
		assertTrue(manager != null);
        
		var page = manager.createPage("pages.test1", null);
		assertTrue(page != null);
		
		var template = manager.get("components.set1.randnum");
		assertTrue(template != null);
        assertEquals("components.set1.randnum.Server", template.serverClassName);
		
		var randnum = manager.createComponent(page, "randnum", "rn", null, null, false);
		assertTrue(randnum != null);
		assertEquals("components.set1.randnum.Server", Type.getClassName(Type.getClass(randnum)));
		
		randnum.callMethodForEach("preRender");
		var html = randnum.render();
		assertEquals(StringTools.htmlEscape("<div id='rn-n'>123</div>"), StringTools.htmlEscape(html.trim(" \t\r\n")));
	}
	
	public function testPlaceHolders()
	{
		Lib.profiler = new Profiler(true);
		
		var manager = new HaqTemplateManager();
		assertTrue(manager != null);
		
		var template = manager.get("pages.test2");
		assertTrue(template != null);
        assertEquals("0b2ac", template.getDocCopy().innerHTML);
        //assertEquals(0, template.doc.children.length);
        
		var page = manager.createPage("pages.test2", null);
		assertTrue(page != null);
		
		//trace("RESULT = " + page.render());
	}*/
	
	public function testProfiler()
	{
		Lib.profiler = new Profiler(true);
		Lib.manager = new HaqTemplateManager();
		
		var config = HaqConfig.load("");
		
		var page = Lib.manager.createPage("pages.test3", { config:config, storage:new haquery.common.HaqStorage() });
		assertTrue(page != null);
		
		page.callMethodForEach("init", false);
		
		page.render();
		
		Lib.profiler.traceResults(5, 100);
	}
}