package js.jQueryPlugins;

class NumberFormat
{
	static function __init__() : Void
	{
		haxe.macro.Tools.includeFile("js/jQueryPlugins/NumberFormat.js");
	}
	
	public static inline function numberFormat(jq:js.JQuery, n:Float, params : { 
		numberOfDecimals : Int /*=2*/,
		decimalSeparator : String /*=","*/,
		thousandSeparator : String /*="."*/,
		currencySymbol : String /*=""*/
	}) : String untyped
	{
		return jq.number_format(n, params);
	}
}