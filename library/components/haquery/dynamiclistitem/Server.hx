package components.haquery.dynamiclistitem;

class Server extends components.haquery.listitem.Server
{
    function preRender()
    {
        var docs = new Hash<String>();
		fillDocs("", innerNode, docs);
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
				if (componentTemplate == null)
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