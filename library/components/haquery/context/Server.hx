package components.haquery.context;

import haquery.server.HaqComponent;

class Server extends HaqComponent
{
    public var dataID(dataID_getter, null) : String;
    function dataID_getter() : String
    {
        return q('#dataID').val();
    }
    
    public var position : String;
    
    function preRender()
    {
        if (position != null)
        {
            var positionEnum = switch (position)
            {
                case "rightOuter": ContextPanelPosition.rightOuter;
                case "rightTopInner": ContextPanelPosition.rightTopInner;
            };
            
            q('#p').attr('position', Std.string(Type.enumIndex(positionEnum)));
        }
    }
}
