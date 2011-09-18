package haquery.components.tabs;

import haquery.server.HaqComponent;

class Server extends HaqComponent
{
    function bind(tabs:Array<Tab>)
    {
        var s = '';
        for (t in tabs)
        {
            var name = t.name!=null ? t.name : t.id;
            if (name!='')
            {
                s += "<div id='" + prefixID + t.id + "'";
                if (t.panelID != null) s += " panelID='" + t.panelID + "'";
                s += ">" + t.name + "</div>";
            }
        }
        q('#tabs').html(s);
    }
}
