package haquery;

using haquery.StringTools;

private typedef Params = List<{name:String, value:String}>;

class UrlTools
{
    static function parse(url:String) : { prefix:String, params:Params }
	{
		var n = url.indexOf("?");
		if (n >= 0)
		{
			var params : Params = new Params();
			var paramStrings = url.substr(n + 1).split('&');
			for (paramString in paramStrings)
			{
				var nameAndValue = paramString.split("=");
				params.push( { name:nameAndValue[0], value:(nameAndValue.length > 1 ? nameAndValue[1] : null) } );
			}
			return { prefix:url.substr(0, n), params:params };
		}
		else
		{
			return { prefix:url, params:new Params() };
		}
	}
	
	static function combine(prefix:String, params:Params) : String
	{
		var url = prefix;
		if (params.length > 0)
		{
			url += '?';
			for (param in params)
			{
				url += param.name;
				if (param.value != null) url += '=' + param.value;
				url += '&';
			}
			url = url.substr(0, url.length - 1);
		}
		return url;
	}
	
    public static function isParamExist(url:String, name:String) : Bool
    {
		return Lambda.exists(parse(url).params, function(param) return param.name == name);
    }
    
	public static function setParam(url:String, name:String, value:Dynamic) : String
    {
		var data = parse(url);
		for (param in data.params)
		{
			if (param.name == name)
			{
				param.value = Std.string(value);
				return combine(data.prefix, data.params);
			}
		}
		data.params.push( { name:name, value:value } );
		return combine(data.prefix, data.params);
    }
    
    public static function getParam(url:String, name:String, defValue:String=null) : String
    {
		var data = parse(url);
		for (param in data.params)
		{
			if (param.name == name)
			{
				return param.value;
			}
		}
		return defValue;
    }
	
    public static function getParamInt(url:String, name:String, defValue:Int=0) : Int
    {
		var r = Std.parseInt(getParam(url, name, Std.string(defValue)));
		return r != null ? r : defValue;
    }
    
    public static function removeParam(url:String, name : String) : String
    {
		var data = parse(url);
		data.params = Lambda.filter(data.params, function(param) return param.name != name);
		return combine(data.prefix, data.params);
    }
}
