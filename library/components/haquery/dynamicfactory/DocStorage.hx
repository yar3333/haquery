package components.haquery.dynamicfactory;

import haquery.server.HaqSharedStorage;
import haxe.htmlparser.HtmlDocument;
import haxe.htmlparser.HtmlNodeElement;

#if !client
typedef Manager = haquery.server.HaqTemplateManager
typedef StoreType = Server;
#else
typedef Manager = haquery.client.HaqTemplateManager
typedef StoreType = Client;
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
		manager.sharedStorage.setComponentTemplateVar(StoreType, "doc:" + fullTag, doc.toString());
	}
	
	public function get(fullTag:String) : HtmlNodeElement
	{
		var html = manager.sharedStorage.getComponentTemplateVar(StoreType, "doc:" + fullTag);
		if (html == null)
		{
			return null;
		}
		return new HtmlDocument(html);
	}
}