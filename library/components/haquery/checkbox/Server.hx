package components.haquery.checkbox;

import haquery.Std;

class Server extends BaseServer
{
    public var checked(get_checked, set_checked) : Bool;
	public var text : String;
    
	function get_checked() : Bool
	{
		if (!page.isPostback)
		{
			return Std.bool(template().checkbox.attr("checked"));
		}
		else
		{
			return Std.bool(template().checkbox.val());
		}
	}
	
	function set_checked(v:Bool) : Bool
	{
		template().checkbox.val(v);
		return v;
	}
	
    function preRender()
    {
		if (text != null)
		{
			template().text.html(text);
		}
		else
		{
			template().text.remove();
		}
    }
	
	override function loadFieldValues(params:Hash<Dynamic>) 
	{
		super.loadFieldValues(params);
		
		if (!page.isPostback)
		{
			if (params.exists("checked"))
			{
				checked = Std.bool(params.get("checked"));
			}
		}
	}
}