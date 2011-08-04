package haquery.server;

import php.Lib;

class HaqInternals 
{
	public static inline var DELIMITER = '-';
	
	/**
	 * JavaScript, который будет возвращён в результате ajax-запроса.
	 * В частности, в эту переменную HaqQuery складывает вызовы ф-й jQuery.
	 * @var string
	 */
	static var ajaxAnswer = '';

	public static function addAjaxAnswer(jsCode:String) 
	{
		ajaxAnswer += jsCode + "\n";
	}
	
	public static function getAjaxAnswer() : String
	{
		return ajaxAnswer;
	}
}