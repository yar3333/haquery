package components.haquery.checkbox;

import haquery.server.HaqComponent;
import haquery.server.Lib;
import haquery.Std;

class Server extends HaqComponent
{
    public var checked(getChecked, setChecked) : Bool;
	public var text : String;
    
	function getChecked() : Bool
	{
		if (!page.isPostback)
		{
			return Std.bool(q('#cb').attr("checked"));
		}
		else
		{
			return Std.bool(q('#cb').val());
		}
	}
	
	function setChecked(v:Bool) : Bool
	{
		q('#cb').val(v);
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
	
	override function loadFieldValues(params:Hash<String>) 
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