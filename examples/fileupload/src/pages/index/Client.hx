package pages.index;

import haquery.client.HaqComponent;
import haquery.client.HaqPage;

class Client extends HaqPage
{
    function fu_select(t, e)
    {
        q('#status').html("select");
        trace("select");
    }
    
    function fu_filterNotMatch(t, e)
    {
        q('#status').html("filterNotMatch");
        trace("filterNotMatch");
    }

    function fu_uploading(t, e)
    {
        q('#status').html("uploading");
        trace("uploading");
    }
    
    function fu_complete(t, e)
    {
        var text = "";
		for (id in e.keys())
		{
			var f = e.get(id);
			text += "file uploaded: fileID = " + f.fileID + ", error = " + f.error + "<br />";
		}
		q('#status').html(text);
    }
}