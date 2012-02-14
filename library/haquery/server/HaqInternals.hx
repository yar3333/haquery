package haquery.server;

class HaqInternals 
{
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