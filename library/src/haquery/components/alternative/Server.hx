package haquery.components.alternative;

typedef Container = haquery.components.container.Server;

class Server extends Container
{
    public var active : Int;
    
    function new()
    {
        super();
        active = 0;
    }
    
    function preRender()
    {
        q('>*').each(function(index, elem) {
            if (index != active)
            {
                elem.remove();
            }
        });
    }
}