package haquery.server;

typedef HaqResponse =
{
	var responseHeaders : HaqResponseHeaders;
	var statusCode : Int;
	var cookie : HaqResponseCookie;
	var content : String;
	var ajaxResponse : String;
	var result : Dynamic;
}
