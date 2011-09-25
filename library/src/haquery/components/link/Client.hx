package haquery.components.link;

import haquery.client.HaQuery;

class Client extends Base
{
    function link_click()
    {
        HaQuery.redirect(q('#href').val());
        return false;
    }
}
