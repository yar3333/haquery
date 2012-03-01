package haquery;

class Localization 
{
    /**
     * @param	n Number
     * @param	w1 1,11, .. numeral
     * @param	w2 2, 3, .. numeral
     * @param	w3 0, 5, .. numeral
     * @return Numeral
     */
	public static function getNumeral(n:Int, w1:String, w2:String, w3:String) : String
    {
        if (n % 10 == 0 || (n >= 11 && n<=19) || n%10>=5) return w3;
        if (n % 10 >= 2 && n % 10 <= 4) return w2;
        return w1;
    }
}