package haquery.client.template_parser;

import haquery.client.HaqDefines;
import haquery.client.HaqInternals;
import haquery.client.HaqComponent;

class ComponentTemplateParser 
{
	var collection : String;
	var tag : String;
	var extendsCollection : String;
	
	public function new(collection:String, tag:String, extendsCollection:String)
	{
		this.collection = collection;
		this.tag = tag;
		this.extendsCollection = extendsCollection;
	}
	
	public function getClientClass() : Class<HaqComponent>
	{
		var className = HaqDefines.folders.components + "." + collection + "." + tag + ".Client";
		var clas = Type.resolveClass(className);
		if (clas != null)
		{
			return cast clas;
		}
		
		if (extendsCollection != null)
		{
			return getClientClassName(extendsCollection, tag);
		}
		
		return HaqComponent;
	}
}