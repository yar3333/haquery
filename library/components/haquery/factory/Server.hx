package components.haquery.factory;

import htmlparser.HtmlNodeElement;
import haquery.common.HaqStorage;
import haquery.common.HaqComponentTools;
import haquery.server.Lib;
import stdlib.Exception;
using stdlib.StringTools;

class Server extends BaseServer
{
	function postInit()
	{
		if (visible)
		{
			storeDocs(parent.fullTag, innerNode);
			page.storage.setInstanceVar(fullID, "html", innerNode.innerHTML, HaqStorage.DESTINATION_CLIENT);
		}
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
					page.storage.setStaticVar(Server, t.fullTag, t.serializedDoc, HaqStorage.DESTINATION_CLIENT);
					storeDocs(t.fullTag, t.doc);
				}
			}
			storeDocs(parentFullTag, child);
		}
	}
}