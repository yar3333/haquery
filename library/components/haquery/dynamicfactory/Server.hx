package components.haquery.dynamicfactory;

import haquery.common.HaqComponentTools;
import haxe.htmlparser.HtmlNodeElement;
import haxe.Serializer;
import haquery.Exception;
using haquery.StringTools;

class Server extends BaseServer
{
    function preRender()
    {
		var storage = new DocStorage(manager);
		storeDocs(parent.fullTag, innerNode, storage);
		q("#html").val(Serializer.run(innerNode.innerHTML));
    }
	
	function storeDocs(parentFullTag:String, parentDoc:HtmlNodeElement, storage:DocStorage)
	{
		for (child in parentDoc.children)
		{
			if (child.name.startsWith("haq:"))
			{
				var tag = HaqComponentTools.htmlTagToFullTag(child.name.substr("haq:".length));
				var t = manager.get(tag);
				if (t == null)
				{
					throw new Exception("Could not find template for the '" + tag + "' component for the '" + parentFullTag + "' parent component.");
				}
				
				if (storage.get(t.fullTag) == null)
				{
					var doc = t.getDocCopy();
					storage.set(t.fullTag, doc);
					storeDocs(t.fullTag, doc, storage);
				}
			}
			storeDocs(parentFullTag, child, storage);
		}
	}
}