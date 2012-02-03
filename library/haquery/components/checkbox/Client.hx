package haquery.components.checkbox;

import haquery.client.HaqComponent;

class Client extends HaqComponent
{
    public var value(value_getter, value_setter) : Bool;
    
    function value_getter() : Bool
    {
        return q('#value').val() != "0";
    }
    
    function value_setter(v:Bool) : Bool
    {
		untyped q('#check')[0].checked = v;
		q('#value').val(v ? '1' : '0');
        return v;
    }
    
    function check_change()
    {
        q('#value').val(q('#check').is(":checked") ? '1' : '0');
    }
}