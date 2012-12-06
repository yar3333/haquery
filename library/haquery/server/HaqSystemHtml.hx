package haquery.server;

#if server

using haquery.StringTools;

class HaqSystemHtml 
{
	static var template = '<!DOCTYPE html>
<html>
	<head>
		<title>Status - HaQuery</title>
		<style>
{rawStyle}
		</style>
		<script src="/haquery/client/jquery.js"></script>
		<script>
			function setCookie(c_name, value, exdays)
			{
				var exdate = new Date();
				exdate.setDate(exdate.getDate() + exdays);
				var c_value = escape(value) + (exdays == null ? "" : "; expires=" + exdate.toUTCString());
				document.cookie = c_name + "=" + c_value + "; path=/";
			}
			
{rawJs}
		</script>
	</head>
	<body>
{rawContent}
	</body>
</html>';
	
	var rawStyle = "";
	var rawJs = "";
	var rawContent = "";
	
	var tags : Array<String>;
	
	public function new()
	{
		tags = [];
	}
	
	public function begin(tag:String, ?params:String) : HaqSystemHtml
	{
		tags.push(tag);
		rawContent += "<" + tag + (params != null && params != "" ? " " + params : "") + ">";
		return this;
	}
	
	public function end() : HaqSystemHtml
	{
		var tag = tags.pop();
		rawContent += "</" + tag + ">";
		return this;
	}
	
	public function content(s:String) : HaqSystemHtml
	{
		rawContent += s;
		return this;
	}
	
	public function style(selector, styles:Array<String>) : HaqSystemHtml
	{
		rawStyle += "\n			" + selector + "\n"
			   + "			" + "{\n"
			   + "				" + styles.join(";\n				") + ";\n"
			   + "			" + "}\n";
		return this;
	}
	
	public function js(s:String) : HaqSystemHtml
	{
		rawJs += "			" + s.replace("\n", "\n			") + "\n";
		return this;
	}
	
	public function link(s:String, url:String, ?onclick:String) : HaqSystemHtml
	{
		rawContent += "<a href='" + url + "'" + (onclick != null ? " onclick=\"" + onclick + "\"" : "") + ">" + s + "</a>";
		return this;
	}
	
	public function anchor(s:String, name:String) : HaqSystemHtml
	{
		rawContent += "<a name='" + name + "'>" + s + "</a>";
		return this;
	}
	
	public function bold(s:String) : HaqSystemHtml
	{
		rawContent += "<b>" + s + "</b>";
		return this;
	}
	
	public function toString() : String
	{
		return template.replace("{rawStyle}", rawStyle).replace("{rawJs}", rawJs).replace("{rawContent}", rawContent);
	}
}

#end