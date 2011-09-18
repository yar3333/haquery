package pages.index;

import haquery.server.HaqPage;
import haquery.server.HaqTools;
import php.io.Path;
import php.Web;

class Server extends HaqPage
{
    public function fu_upload(t, file:UploadedFile)
    {
        q('#status').html("upload " + file.name);
        file.move('uploads/' + Path.withoutDirectory(file.name));
    }
}