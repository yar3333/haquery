package haquery.server;

import php.Lib;

class HaqInternals 
{
	/**
	 * Delimiter for IDs in fullID.
	 */
    public static inline var DELIMITER = '-';
	
	/**
	 * JavaScript code for ajax response.
	 */
	static var ajaxAnswer = "";

	public static function addAjaxAnswer(jsCode:String) 
	{
		ajaxAnswer += jsCode + "\n";
	}
	
	public static function getAjaxAnswer() : String
	{
		return ajaxAnswer;
	}
}