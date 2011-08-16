package haquery.components.consts;

import haquery.server.HaqComponent;

class Server extends HaqComponent
{
    public static var consts : Hash<String> = new Hash<String>();
    
    override function render() : String
    {
        var text = innerHTML;
        for (const in consts.keys())
        {
            text = text.replace('{' + const + '}', consts.get(const));
        }
        return text;
    }
}