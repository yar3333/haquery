package components.haquery.link;

import haquery.client.Lib;

class Client extends Base
{
    function link_click(t, e)
    {
        page.redirect(q('#href').val());
        return false;
    }
}
