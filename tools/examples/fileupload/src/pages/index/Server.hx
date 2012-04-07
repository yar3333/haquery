package pages.index;

import haquery.server.HaqComponent;
import haquery.server.HaqPage;
import haquery.server.Web;
import php.io.Path;

class Server extends HaqPage
{
    function fu_upload(t:HaqComponent, file:UploadedFile)
    {
        q('#status').html("upload " + file.name);
        file.move('uploads/' + Path.withoutDirectory(file.name));
    }
}