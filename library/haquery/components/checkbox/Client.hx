package haquery.components.checkbox;

import haquery.client.HaqComponent;
import haquery.client.HaqEvent;

class Client extends HaqComponent
{
    var event_change : HaqEvent;
	
	public var checked(checked_getter, checked_setter) : Bool;
    
    function checked_getter() : Bool
    {
        return untyped q('#cb')[0].checked;
    }
    
    function checked_setter(v:Bool) : Bool
    {
        untyped q('#cb')[0].checked = v;
        return v;
    }
    
    function cb_change(e)
    {
		event_change.call([ e ]);
    }
}