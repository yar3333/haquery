package haquery.base;

import haquery.common.HaqSharedStorage;

class HaqTemplateManager<Template:HaqTemplate>
{
	#if !client
	var templates(default, null) : Hash<Template>;
	#end
	
	/**
	 * Vars to be (was) sended to the client.
	 */
	public var sharedStorage(default, null) : HaqSharedStorage;
	
	public function new()
	{
		#if !client
		templates = new Hash<Template>();
		#end
		sharedStorage = new HaqSharedStorage();
	}
	
	#if !client
	public function get(fullTag:String) : Template
	{
		if (templates.exists(fullTag))
		{
			var r = templates.get(fullTag);
			if (r == null)
			{
				r = newTemplate(fullTag);
				templates.set(fullTag, r);
			}
			return r;
		}
		return null;
	}
	#end
	
	#if !client
	function newTemplate(fullTag:String) : Template
	{
		return null; 
	}
	#end
}