package components.haquery.checkbox;

import haquery.client.HaqComponent;
import haquery.client.HaqEvent;

class Client extends HaqComponent
{
    var event_change : HaqEvent<js.JQuery.JqEvent>;
	
	public var checked(checked_getter, checked_setter) : Bool;
    
    function checked_getter() : Bool
    {
        return cast q('#cb').prop('checked');
    }
    
    function checked_setter(v:Bool) : Bool
    {
        q('#cb').prop('checked', v);
        return v;
    }
    
    function cb_change(t, e:js.JQuery.JqEvent)
    {
		event_change.call(e);
    }
	
	@shared function setChecked(v:Bool)
	{
		checked = v;
	}
}