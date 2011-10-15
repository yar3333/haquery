package haquery;

class HashTools
{
    public static function add<T>(dest:Hash<T>, src:Hash<T>, overwrite = true)
    {
        if (overwrite)
        {
            for (key in src.keys())
            {
                dest.set(key, src.get(key));
            }
        }
        else
        {
            for (key in src.keys())
            {
                if (!dest.exists(key))
                {
                    dest.set(key, src.get(key));
                }
            }
        }
    }
    
    public static function values<T>(h:Hash<T>) : Array<T>
    {
        var r = new Array<T>();
        for (key in h.keys())
        {
            r.push(h.get(key));
        }
        return r;
    }
}