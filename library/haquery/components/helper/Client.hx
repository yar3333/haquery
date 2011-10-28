package haquery.components.helper;

import haquery.client.HaqQuery;
import haquery.client.Lib;
import haquery.client.HaqComponent;

class Client extends HaqComponent
{
    var selector : String;
    var rootNode : HaqQuery;
    
    function init()
    {
        var input = q('#selector');
        selector = input.val();
        rootNode = input.parent();
        input.remove();
        update();
    }
    
    public function update()
    {
        apply(new HaqQuery(selector, rootNode));
    }
    
    public function apply(elems:HaqQuery)
    {
        Lib.assert(false, "Need to overload the 'apply' method.");
    }
}