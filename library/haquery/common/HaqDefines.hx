package haquery.common;

class HaqDefines 
{
	public static inline var VERSION = 5.0;
	
	public static var folders = {
		  pages : 'pages'
		, components : 'components'
		, support : 'support'
		, temp : 'temp'
	};
	
	/**
	 * Delimiter for IDs in fullID.
	 */
    public static inline var DELIMITER = '-';
	
    public static var elemEventNames =
	[
		'click', 'change', 'load',
		'mousedown', 'mouseup', 'mousemove',
		'mouseover', 'mouseout', 'mouseenter', 'mouseleave',
		'keypress', 'keydown', 'keyup', 
		'focus', 'blur', 'focusin', 'focusout'
    ];
}