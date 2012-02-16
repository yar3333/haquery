/*
package haquery.base;

#if (php || neko)
import haquery.server.HaqTemplate;
import haxe.Serializer;
typedef ComponentCollection = haquery.server.HaqComponentCollection;
#elseif js
import haquery.client.HaqTemplate;
typedef ComponentCollection = haquery.client.HaqComponentCollection;
#end

private typedef HaqComponentCollectionData = 
{
	var name : String;
	var imports : Array<String>;
	var tagExtends : Hash<String>;
}

class HaqComponentCollection 
{
	static var collections = new Hash<ComponentCollection>();
	
	var name : String;
	var imports : Array<ComponentCollection>;
	var templates : Hash<HaqTemplate>;
	
	public function new(name:String, imports:Array<ComponentCollection>, templates:Hash<HaqTemplate>)
	{
		this.name = name;
		this.imports = imports;
		this.templates = templates;
	}
	
	public function getTemplate(parent:HaqComponent, tag:String) : HaqTemplate
	{
		if (templates.exists(tag))
		{
			return templates.get(tag);
		}
		
		for (collection in imports)
		{
			var r = collection.getTemplate(parent, tag);
			if (r != null)
			{
				return r;
			}
		}
		
		return null;
	}
	
	public function serialize() : String
	{
		var tagExtends = new Hash<String>();
		for (tag in templates.keys())
		{
			tagExtends.set(tag, templates.get(tag).extendsCollection);
		}
		
		return Serializer.run( { 
			 name : name
			,imports : Lambda.map(imports, function(c) return c.serialize)
			,inhehitances : inhehitances
		});
	}
}
*/