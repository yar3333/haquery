package components.haquery.checkbox;

import haquery.common.HaqEvent;
import haquery.Std;
import js.JQuery;

class Client extends BaseClient
{
    var event_change : HaqEvent<JqEvent>;
	
	public var checked(get_checked, set_checked) : Bool;
    
    function get_checked() : Bool
    {
        return cast template().checkbox.prop('checked');
    }
    
    @shared function set_checked(v:Bool) : Bool
    {
        template().checkbox.prop('checked', v);
        return v;
    }
    
    function checkbox_change(t, e)
    {
		event_change.call(e);
    }
}