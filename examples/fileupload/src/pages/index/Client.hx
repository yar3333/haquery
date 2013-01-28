package pages.index;

class Client extends BaseClient
{
    function fu_select(t, e)
    {
        q('#status').html("select");
        trace("select");
    }
    
    function fu_uploading(t, e)
    {
        q('#status').html("uploading");
        trace("uploading");
    }
    
    function fu_complete(t, e)
    {
        var text = "";
		for (inputID in e.uploads.keys())
		{
			var f = e.uploads.get(inputID);
			text += "file uploaded: inputID = " + inputID + ", fileID = " + f.fileID + ", error = " + f.error + "<br />";
		}
		q('#status').html(text);
		
		q('#status').html(q('#status').html() + "Now move file(s) to uploads folder...");
		var fileIDs = Lambda.map( { iterator:e.uploads.keys }, function(inputID) return e.uploads.get(inputID).fileID);
		server().saveFiles(fileIDs, function()
		{
			q('#status').html(q('#status').html() + " OK");
		});
    }
}