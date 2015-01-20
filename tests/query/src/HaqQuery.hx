package ;

import htmlparser.HtmlNodeElement;
import stdlib.StringTools;

class HaqQuery extends haquery.server.HaqQuery
{
	public function new(nodes:Array<HtmlNodeElement>)
	{
		super(
			  cast { prefixID:"mypref", page: { isPostback:false, params:new Map<String, String>(), addAjaxResponse:function(s) { } } }
			, null
			, "thisIsOriginalQuery"
			, nodes
		);
	}
}
