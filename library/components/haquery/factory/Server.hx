package components.haquery.factory;

import haquery.server.Lib;
import haquery.common.HaqComponentTools;
import haxe.htmlparser.HtmlNodeElement;
import stdlib.Exception;
using stdlib.StringTools;

class Server extends BaseServer
{
    function preRender()
    {
		storeDocs(parent.fullTag, innerNode);
		page.storage.setInstanceVar(this, "html", innerNode.innerHTML);
    }
	
	function storeDocs(parentFullTag:String, parentDoc:HtmlNodeElement)
	{
		for (child in parentDoc.children)
		{
			if (child.name.startsWith("haq:"))
			{
				var tag = HaqComponentTools.htmlTagToFullTag(child.name.substr("haq:".length));
				var t = Lib.manager.get(tag);
				if (t == null)
				{
					throw new Exception("Could not find template for the '" + tag + "' component for the '" + parentFullTag + "' parent component.");
				}
				
				if (!page.storage.existsStaticVar(Server, t.fullTag))
				{
					var doc = t.getDocCopy();
					page.storage.setStaticVar(Server, t.fullTag, doc);
					storeDocs(t.fullTag, doc);
				}
			}
			storeDocs(parentFullTag, child);
		}
	}
}