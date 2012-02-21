package haquery.components.templater;

import haquery.server.Lib;
import haquery.server.HaqComponent;

class Server extends HaqComponent
{
	override function createChildComponents()
	{
		if (doc != null)
		{
			manager.createDocComponents(this, doc, false);
		}
	}
}