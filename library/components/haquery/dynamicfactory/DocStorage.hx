package components.haquery.dynamicfactory;

import haquery.server.HaqSharedStorage;
import haxe.htmlparser.HtmlDocument;
import haxe.htmlparser.HtmlNodeElement;

#if (php || neko)
typedef Manager = haquery.server.HaqTemplateManager
#elseif js
typedef Manager = haquery.client.HaqTemplateManager
#end

class DocStorage
{
    var manager : Manager;
	
	public function new(manager:Manager)
	{
		this.manager = manager;
	}
	
	public function set(fullTag:String, doc:HtmlNodeElement)
	{
		manager.componentTemplateStorage.set("components.haquery.dynamicfactory", "doc:" + fullTag, doc.toString());
	}
	
	public function get(fullTag:String) : HtmlNodeElement
	{
		var html = manager.componentTemplateStorage.get("components.haquery.dynamicfactory", "doc:" + fullTag);
		if (html == null)
		{
			return null;
		}
		return new HtmlDocument(html);
	}
}