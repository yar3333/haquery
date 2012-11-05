package components.haquery.checkbox;

import haquery.common.HaqEvent;
import js.JQuery;

class Client extends BaseClient
{
    var event_change : HaqEvent<JqEvent>;
	
	public var checked(getChecked, setChecked) : Bool;
    
    function getChecked() : Bool
    {
        return cast q('#cb').prop('checked');
    }
    
    @shared function setChecked(v:Bool) : Bool
    {
        q('#cb').prop('checked', v);
        return v;
    }
    
    function cb_change(t, e)
    {
		event_change.call(e);
    }
}