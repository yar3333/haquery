package haquery.client;

typedef HaqTemplate =
{ 
	var elemID_serverHandlers: Hash<Array<String>>;
	var clas : Class<HaqComponent>;
}

class HaqTemplates
{
	var componentsFolders : Array<String>;
	var tag_elemID_serverHandlers : Hash<Hash<Array<String>>>;

	public function new(componentsFolders:Array<String>, serverHandlers:Array<Array<Dynamic>>) 
	{
		this.componentsFolders = componentsFolders;
		tag_elemID_serverHandlers = new Hash<Hash<Array<String>>>();
		
		for (sh in serverHandlers)
		{
			var tag : String = sh[0];
			for (i in 1...sh.length)
			{
				var elemID_eventNames : Array<String> = sh[i];
				var elemID : String = elemID_eventNames[0];
				var eventNames : String = elemID_eventNames[1];
				if (!tag_elemID_serverHandlers.exists(tag))
				{
					tag_elemID_serverHandlers.set(tag, new Hash<Array<String>>());
				}
				tag_elemID_serverHandlers.get(tag).set(elemID, eventNames.split(','));
			}
		}
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