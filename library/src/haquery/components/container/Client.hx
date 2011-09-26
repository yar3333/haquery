package haquery.components.container;

import haquery.client.HaqComponent;
import haquery.client.HaqElemEventManager;

class Client extends HaqComponent
{
    override function connectElemEventHandlers():Void 
    {
        if (parent != null)
        {
            HaqElemEventManager.connect(parent, this, manager.templates);
        }
    }
}
