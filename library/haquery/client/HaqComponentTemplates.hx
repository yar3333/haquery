package haquery.client;

using haquery.StringTools;

typedef HaqTemplate =
{ 
	var elemID_serverHandlers: Hash<Array<String>>;
	var clas : Class<HaqComponent>;
}

class HaqComponentTemplates
{
	var componentsFolders : Array<String>;
	var tag_elemID_serverHandlers : Hash<Hash<Array<String>>>;

	public function new(componentsFolders:Array<String>, tag_elemID_serverHandlers:Hash<Hash<Array<String>>>) 
	{
		this.componentsFolders = componentsFolders;
		this.tag_elemID_serverHandlers = tag_elemID_serverHandlers;
	}
	
	public function get(tag:String) : HaqTemplate
	{
		var r : HaqTemplate = { elemID_serverHandlers : tag_elemID_serverHandlers.get(tag), clas : null };
		
		var i = componentsFolders.length - 1;
		while (i >= 0)
		{
			var folder = componentsFolders[i];
			var className = folder.replace('/', '.') + tag + '.Client';
			var clas : Class<HaqComponent> = untyped Type.resolveClass(className);
			if (clas != null)
			{
				r.clas = clas;
				break;
			}
			i--;
		}
		if (r.clas == null) r.clas = untyped Type.resolveClass('haquery.client.HaqComponent');
		
		return r; 
	}
}