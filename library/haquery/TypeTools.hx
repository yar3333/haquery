package haquery;

class TypeTools 
{
    public static function isExtends(c:Class<Dynamic>, superClass:Class<Dynamic>)
    {
        while (c != null)
        {
            if (c == superClass) return true;
            c = Type.getSuperClass(c);
        }
        return false;
    }
}