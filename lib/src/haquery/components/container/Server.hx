package haquery.components.container;

import haquery.server.HaqComponent;
import haquery.server.HaqComponentManager;
import haquery.server.HaqXml;

class Server extends HaqComponent
{
	override public function construct(manager:HaqComponentManager, parent:HaqComponent, tag:String, id:String, doc:HaqXml, params:Dynamic, innerHTML:String) : Void
	{
        super.construct(manager, parent, tag, id, new HaqXml(getHeader()+innerHTML+getFooter()), params, '');
	}
    
    /**
     * Override in the child class to specify header
     */
    function getHeader() : String
    {
        return '';
    }
    
    /**
     * Override in the child class to specify footer
     */
    function getFooter() : String
    {
        return '';
    }
}
