package pages.index;

import sys.FileSystem;
import haquery.server.Lib;

class Server extends BaseServer
{
	@shared function saveFiles(fileIDs:List<String>)
	{
		for (fileID in fileIDs)
		{
			var file = Lib.uploads.get(fileID);
			trace("Move file " + file.path + " to uploads/" + file.name + ".");
			FileSystem.rename(file.path, "uploads/" + file.name);
		}
	}
}