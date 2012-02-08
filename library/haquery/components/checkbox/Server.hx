package haquery.components.checkbox;

import haquery.server.HaqComponent;
import haquery.server.Lib;
import haquery.Std;

class Server extends HaqComponent
{
    public var checked(checked_getter, checked_setter) : Bool;
	public var text : String;
    
    function checked_getter() : Bool
	{
		if (!Lib.isPostback)
		{
			return q('#cb').attr("checked") ? true : false;
		}
		else
		{
			return q('#cb').val();
		}
	}
	
	function checked_setter(v:Bool) : Bool
	{
		q('#cb').val(v);
		
		if (Lib.isPostback)
		{
			callSharedMethod("setChecked", [ v ]);
		}
		
		return v;
	}
	
    function preRender()
    {
		if (text != null)
		{
			cast(components.get("text"), haquery.components.literal.Server).text = " " + text;
		}
    }
	
	override function loadFieldValues(params:Hash<String>) 
	{
		super.loadFieldValues(params);
		
		if (!Lib.isPostback)
		{
			if (params.exists("checked"))
			{
				checked = Std.bool(params.get("checked"));
			}
		}
	}
}