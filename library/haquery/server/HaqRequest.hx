package haquery.server;

#if server

typedef HaqRequest =
{
	var pageFullTag : String;
	
    /**
     * Last unexist URL part will be placed to this var. 
     * For example, if your request "http://site.com/news/123"
     * then pageID will be "123".
     */
    var pageID : String;
    
	/**
     * false => rendering html, true => calling server event handler.
     */
    var isPostback : Bool;

	var params : Hash<String>;
	
	var cookie : HaqCookie;
	
	var requestHeaders : HaqRequestHeaders;
	
	var clientIP : String;
	
	var uri : String;
	
	var host : String;
	
	var queryString : String;
	
	var pageKey : String;
	
	var pageSecret : String;
	
	var config : HaqConfig;
	
	var db : haquery.server.db.HaqDb;
}

#end