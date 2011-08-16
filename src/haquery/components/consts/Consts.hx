package haquery.components.consts;

class Consts 
{
    public static function set(name:String, val:String) : Void
    {
        Server.consts.set(name, val);
    }
    
    public static function get(name:String) : String
    {
        return Server.consts.get(name);
    }
}