package national;

class StringTools
{
    #if php
    public static inline function toUpperCase(s : String) : String
    {
        return untyped __call__('mb_strtoupper', s, 'UTF-8');
    }
    
    public static inline function toLowerCase(s : String) : String
    {
        return untyped __call__('mb_strtolower', s, 'UTF-8');
    }
    #end
}