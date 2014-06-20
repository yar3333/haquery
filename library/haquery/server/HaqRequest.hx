package haquery.server;

#if server

class HaqRequest
{
	public var pageFullTag : String;
	
    /**
     * Last unexist URL part will be placed to this var. 
     * For example, if your request "http://site.com/news/123"
     * then pageID will be "123".
     */
    public var pageID : String;
    
	/**
     * false => rendering html, true => calling server event handler.
     */
    public var isPostback : Bool;

	public var params : HaqParams;
	
	public var cookie : HaqCookie;
	
	public var requestHeaders : HaqRequestHeaders;
	
	public var clientIP : String;
	
	public var uri : String;
	
	public var host : String;
	
	public var queryString : String;
	
	public var config : HaqConfig;
	
	public var storage : haquery.common.HaqStorage;
	
	public function new(
		  pageFullTag : String
		, pageID : String
		, isPostback : Bool
		, params : HaqParams
		, cookie : HaqCookie
		, requestHeaders : HaqRequestHeaders
		, clientIP : String
		, uri : String
		, host : String
		, queryString : String
		, config : HaqConfig
		, storage : haquery.common.HaqStorage
	) {
		this.pageFullTag = pageFullTag;
		this.pageID = pageID;
		this.isPostback = isPostback;
		this.params = params;
		this.cookie = cookie;
		this.requestHeaders = requestHeaders;
		this.clientIP = clientIP;
		this.uri = uri;
		this.host = host;
		this.queryString = queryString;
		this.config = config;
		this.storage = storage;
	}
}

#end