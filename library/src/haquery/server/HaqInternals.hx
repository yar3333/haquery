package haquery.server;

import php.Lib;

class HaqInternals 
{
	/**
	 * Delimiter for IDs in fullID.
	 */
    public static inline var DELIMITER = '-';
	
	static var ajaxResponse = "";

	public static function addAjaxResponse(jsCode:String) 
	{
		ajaxResponse += jsCode + "\n";
	}
	
	public static function getAjaxResponse() : String
	{
		return ajaxResponse;
	}
}