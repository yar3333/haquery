package haquery.components.tabs;

import haquery.client.HaqQuery;
import haquery.client.HaqEvent;
import haquery.client.HaqComponent;

class Client extends HaqComponent
{
    var event_selected : HaqEvent;
    var event_hided : HaqEvent;

    function init()
    {
        var self = this;
        q('#tabs div').click(function(e) {
            self.select(e.target.id.substr(self.prefixID.length));
        });

        var divs = q('#tabs>div');
        if (divs.length > 0)
        {
            select(divs[0].id.substr(this.prefixID.length));
        }
    }

    public function select(tabID)
    {
        var self = this;
        q('#tabs>div').each(function(index,elem) {
            var elemID = elem.id.substr(self.prefixID.length);
            if (elemID!=tabID)
            {
                new HaqQuery(elem).removeClass('active');
                self.parent.q('#' + new HaqQuery(elem).attr('panelID')).removeClass('active');
                self.event_hided.call([elemID]);
            }
        });
        q('#'+tabID).addClass('active');
        parent.q('#' + q('#' + tabID).attr('panelID')).addClass('active');
        event_selected.call([tabID]);
    }
}
