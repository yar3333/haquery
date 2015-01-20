import htmlparser.HtmlDocument;

class QueryTest extends haxe.unit.TestCase
{
    public function testSetStyle()
    {
		var doc = new HtmlDocument("<test style='display:none; margin-top:5px'/>");
		var q = new HaqQuery(doc.children);
		
		q.css("display", "block");
        this.assertEquals("display:block; margin-top:5px", q.attr("style"));
		
		q.css("margin-top", "10px");
        this.assertEquals("display:block; margin-top:10px", q.attr("style"));
    }
    
	public function testGetStyle()
    {
		var doc = new HtmlDocument("<test style='display:none; margin-top:5px'/>");
		var q = new HaqQuery(doc.children);
        this.assertEquals("none", q.css("display"));
        this.assertEquals("5px", q.css("margin-top"));
    }
}
