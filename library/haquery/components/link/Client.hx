package haquery.components.link;

import haquery.client.Lib;

class Client extends Base
{
    function link_click()
    {
        Lib.redirect(q('#href').val());
        return false;
    }
}
