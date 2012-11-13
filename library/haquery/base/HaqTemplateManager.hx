package haquery.base;

import haquery.common.HaqDefines;
import haquery.common.HaqSharedStorage;

using haquery.StringTools;

class HaqTemplateManager<Template:HaqTemplate>
{
	var templates(default, null) : Hash<Template>;
	
	/**
	 * Vars to be (was) sended to the client.
	 */
	public var sharedStorage(default, null) : HaqSharedStorage;
	
	public function new()
	{
		templates = new Hash<Template>();
		sharedStorage = new HaqSharedStorage();
	}
	
	public function get(fullTag:String) : Template
	{
		#if !client
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
		#else
		return templates.get(fullTag);
		#end
	}
	
	#if !client
	function newTemplate(fullTag:String) : Template
	{
		return null; 
	}
	#end
}