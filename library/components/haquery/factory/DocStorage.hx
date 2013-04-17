package components.haquery.factory;

import haxe.htmlparser.HtmlDocument;
import haxe.htmlparser.HtmlNodeElement;
import haquery.common.HaqStorage;

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
		manager.storage.setStaticVar(StoreType, "doc:" + fullTag, doc.toString());
	}
	
	public function get(fullTag:String) : HtmlNodeElement
	{
		var html = manager.storage.getStaticVar(StoreType, "doc:" + fullTag);
		if (html == null)
		{
			return null;
		}
		return new HtmlDocument(html);
	}
}