package haquery.components.splitter;

import php.Lib;
import haquery.server.HaqComponent;

class SplitterComponent extends HaqComponent
{
    public var style : String;
    
    public var firstElementID : String;
    public var secondElementID : String;

    function preRender()
    {
        q('#a').html(firstElementID);
        q('#b').html(secondElementID);
        if (style!=null)
        {
            q('#s').attr('style', style);
        }
    }
}
