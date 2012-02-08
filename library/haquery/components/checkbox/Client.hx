package haquery.components.checkbox;

import haquery.client.HaqComponent;

class Client extends HaqComponent
{
    public var checked(checked_getter, checked_setter) : Bool;
    
    function checked_getter() : Bool
    {
        return q('#checked').val() != "0";
    }
    
    function checked_setter(v:Bool) : Bool
    {
        q('#check').attr('checked', v);
        q('#checked').val(v ? '1' : '0');
        return v;
    }
    
    function check_change()
    {
        q('#checked').val(q('#check').is(":checked") ? '1' : '0');
    }
}