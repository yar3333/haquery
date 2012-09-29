package haquery.server;

typedef HaqRequest =
{
	var uri : String;
	
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
	
	var headers : HaqHeaders;
	
	var uploadedFiles : Hash<HaqUploadedFile>;
}
