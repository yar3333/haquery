package components.haquery.sfactoryitem;

import haquery.client.HaqElemEventManager;

class Client extends Base
{
    override function connectElemEventHandlers():Void 
    {
        if (parent != null && parent.parent != null)
        {
            HaqElemEventManager.connect(parent.parent, this, manager);
        }
    }
}