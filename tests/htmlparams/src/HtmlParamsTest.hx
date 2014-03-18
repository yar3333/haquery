package;

import components.haquery.listitem.Tools;

class HtmlParamsTest extends haxe.unit.TestCase
{
    public function testBasic()
    {
		var params = { abc:"*abc*", def:{ a:"*a*", b:"*b*" } };
		var r = Tools.applyHtmlParams("123{abc}456{def.a}789", params);
        this.assertEquals("123*abc*456*a*789", r);
    }
    
	public function testFirst()
    {
		var params = { abc:"*abc*", def:{ a:"*a*", b:"*b*" } };
		var r = Tools.applyHtmlParams("{abc}456{def.a}789", params);
        this.assertEquals("*abc*456*a*789", r);
	}
	
	public function testLast()
    {
		var params = { abc:"*abc*", def:{ a:"*a*", b:"*b*" } };
		var r = Tools.applyHtmlParams("123{abc}456{def.a}", params);
        this.assertEquals("123*abc*456*a*", r);
	}
	
	public function testNoParams()
    {
		var params = { abc:"*abc*", def:{ a:"*a*", b:"*b*" } };
		var r = Tools.applyHtmlParams("123{abc}456{def.c}789", params);
        this.assertEquals("123*abc*456{ghi}789", r);
	}
}
