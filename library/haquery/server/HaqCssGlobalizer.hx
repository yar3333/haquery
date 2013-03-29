package haquery.server;

#if server

import haxe.htmlparser.HtmlNodeElement;
using stdlib.StringTools;

class HaqCssGlobalizer extends haquery.base.HaqCssGlobalizer
{
	public function styles(text:String) : String
	{
		var re = new EReg("(?:[/][*].*?[*][/])|(?:[{].*?[}])|([^{]+)|(?:[{])", "s");
		
		var r = "";
		
		while (re.match(text))
		{
			if (re.matched(1) != null)
			{
				r += selector(re.matched(0));
			}
			else
			{
				r += re.matched(0);
			}
			text = re.matchedRight();
		}
		
		return r;
	}
	
	public function doc(baseNode:HtmlNodeElement) : Void
	{
		for (node in baseNode.children)
		{
			if (node.hasAttribute("class"))
			{
				node.setAttribute("class", className(node.getAttribute("class")));
			}
			
			if (node.name.startsWith("haq:"))
			{
				if (node.hasAttribute("cssClass"))
				{
					node.setAttribute("cssClass", className(node.getAttribute("cssClass")));
				}
			}
			
			doc(node);
		}
	}
}

#end