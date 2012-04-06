package components.haquery.dynamiclist;

import haxe.htmlparser.HtmlNodeElement;
import haxe.Serializer;

using haquery.StringTools;

class Server extends components.haquery.list.Server
{
    function preRender()
    {
        var docs = new Hash<String>();
		fillDocs("", parent.fullTag, innerNode, docs);
		q("#docs").val(Serializer.run(docs));
    }
	
	function fillDocs(keyFullTag:String, fullTag:String, doc:HtmlNodeElement, docs:Hash<String>)
	{
		docs.set(keyFullTag, doc.toString());
		
		for (child in doc.children)
		{
			if (child.name.startsWith("haq:"))
			{
				var tag = child.name.substr("haq:".length);
				var t = manager.findTemplate(fullTag, tag);
				if (t == null)
				{
					throw "Could not find template for the '" + tag + "' component for the '" + fullTag + "' parent component.";
				}
				if (!docs.exists(keyFullTag))
				{
					fillDocs(fullTag, t.fullTag, t.getDocCopy(), docs);
				}
			}
			fillDocs(keyFullTag, fullTag, child, docs);
		}
	}
}