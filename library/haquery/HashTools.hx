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
    
    /**
     * Make hash on-the-fly.
	 * For example:
		 * var h : Hash<String> = cast haquery.HashTools.hashify({
		 * 	 a: "abc"
		 *  ,b: "def"
		 *  ,c: "ghi"
		 * });
     * @param	obj Generic object to convert to a hash.
     * @return	Result hash.
     */
	public static function hashify(obj:Dynamic) : Hash<Dynamic>
    {
       var r = new Hash<Dynamic>();
       for (key in Reflect.fields(obj))
       {
          r.set(key, Reflect.field(obj, key));
       }
       return r;
    }
}
