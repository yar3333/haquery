package haquery.components.container;

import haquery.client.HaqElemEventManager;

class Client extends Base
{
    override function connectElemEventHandlers():Void 
    {
        if (parent != null)
        {
            HaqElemEventManager.connect(parent, this, manager.templates);
        }
    }
}
