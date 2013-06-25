package ;

import haxe.htmlparser.HtmlAttribute;
import haxe.htmlparser.HtmlDocument;
import haxe.htmlparser.HtmlNodeElement;
import stdlib.StringTools;

class HaqQuery extends haquery.server.HaqQuery
{
	public function new(nodes:Array<HtmlNodeElement>)
	{
		super(
			  cast { prefixID:"mypref", page: { isPostback:false, params:new Hash<String>(), addAjaxResponse:function(s) { } } }
			, null
			, "thisIsOriginalQuery"
			, nodes
		);
	}
}
