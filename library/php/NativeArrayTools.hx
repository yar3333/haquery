package php;

class NativeArrayTools 
{
    public static function count(a:NativeArray) : Int
    {
        return untyped __call__('count', a);
    }
}