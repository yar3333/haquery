package haquery.base;

class HaqDefines 
{
	public static inline var VERSION = 3.0;
	
	public static var folders = {
		 pages : 'pages'
		,components : 'components'
		,support : 'support'
		,temp : 'temp'
	};
	
	/**
	 * Delimiter for IDs in fullID.
	 */
    public static inline var DELIMITER = '-';
	
    public static var elemEventNames : Array<String> = [
		'click', 'change', 'load',
		'mousedown', 'mouseup', 'mousemove',
		'mouseover', 'mouseout', 'mouseenter', 'mouseleave',
		'keypress', 'keydown', 'keyup', 
		'focus', 'focusin', 'focusout',
    ];
}