package components.haquery.dynamiclist;

class Client extends components.haquery.list.Client
{
	var docs : Hash<String>;
	
	function init()
    {
        docs = Unserializer.run(q("#docs").val()); q("#docs").remove();
    }
	
	public function create(parentElem:JQuery, factoryInitParams:Array<Dynamic>)
	{
		if (factoryInitParams == null) factoryInitParams = [];
		
		var doc = new JQuery(docStr);
		for (node in doc)
		{
			prepareDoc(node, "c" + Std.string(length));
		}
		doc.appendTo(parentElem);
		
		HaqElemEventManager.elemsWasChanged();
		
		manager.createComponent(this, "dynamiclistitem", "c" + Std.string(length), factoryInitParams);
		
		q('#length').val(length + 1);
	}
	
	function prepareDoc(node:JQuery, childID:String)
	{
		var id = node.attr("id");
		
		if (id != "")
		{
			node.attr("id", prefixID + childID + HaqDefines.DELIMITER + id);
		}
		
		for (child in node.children())
		{
			prepareDoc(child, childID);
		}
	}
	
	
	public function createDocComponents(parent:HaqComponent, baseNode:HtmlNodeElement, isCustomRender:Bool) : Array<HaqComponent>
    {
		var r = [];
		
		for (node in baseNode.children)
        {
            if (node.name.startsWith('haq:'))
            {
				var tag = node.name.substr('haq:'.length).replace("-", ".");
				r.push(createComponent(parent, tag, node.getAttribute('id'), node.getAttributesAssoc(), node, isCustomRender));
            }
			else
			{
				r = r.concat(createDocComponents(parent, node, isCustomRender));
			}
        }
		
		return r;
    }	
}