package components.haquery.dynamicfactory;

import haxe.htmlparser.HtmlNodeElement;
import haxe.Serializer;

using haquery.StringTools;

class Server extends components.haquery.factory.Server
{
    function preRender()
    {
        var docs = new Hash<String>();
		fillDocs(parent.fullTag, innerNode, docs);
		docs.set("", innerNode.innerHTML);
		q("#docs").val(Serializer.run(docs));
    }
	
	function fillDocs(parentFullTag:String, doc:HtmlNodeElement, docs:Hash<String>)
	{
		for (child in doc.children)
		{
			if (child.name.startsWith("haq:"))
			{
				var tag = child.name.substr("haq:".length);
				var t = manager.findTemplate(parentFullTag, tag);
				if (t == null)
				{
					throw "Could not find template for the '" + tag + "' component for the '" + parentFullTag + "' parent component.";
				}
				if (!docs.exists(t.fullTag))
				{
					var childDoc = t.getDocCopy();
					docs.set(t.fullTag, childDoc.toString());
					fillDocs(t.fullTag, childDoc, docs);
				}
			}
			fillDocs(parentFullTag, child, docs);
		}
	}
}