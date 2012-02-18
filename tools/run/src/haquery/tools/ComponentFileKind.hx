package haquery.tools;

import haquery.server.FileSystem;

using haquery.StringTools;

class ComponentFileKind
{
	var exeDir : String;
	
	public function new(exeDir:String)
	{
		this.exeDir = exeDir;
	}
	
    public function isServerFile(path:String)
    {
        if (path == exeDir + "tools") return false;
		
		if (FileSystem.isDirectory(path))
        {
            return !path.endsWith('.svn');
        }
        return path.endsWith('/Server.hx') || path.endsWith('/Bootstrap.hx');
    }
    
    public function isClientFile(path:String)
    {
		if (path == exeDir + "tools") return false;
		
        if (FileSystem.isDirectory(path))
        {
            return !path.endsWith('.svn');
        }
        return path.endsWith('/Client.hx');
    }
    
    public function isSupportFile(path:String)
    {
		if (path == exeDir + "tools"
		 || path == exeDir + "run.n"
		 || path == exeDir + "restorefiletime.exe"
		 || path == exeDir + "readme.txt"
		 || path == exeDir + "haxelib.xml"
		) return false;
		
		if (FileSystem.isDirectory(path))
		{
			return !path.endsWith(".svn");
		}
		return !path.endsWith(".hx") && !path.endsWith(".hxproj");
    }
    
	public function isSupportFileWithoutComponents(path:String) : Bool
	{
		if (isSupportFile(path))
		{
			return path != exeDir + "haquery/components";
		}
		return false;
	}
    
    public function isNotSvn(path:String)
    {
        if (FileSystem.isDirectory(path))
        {
            return !path.endsWith('.svn');
        }
        return true;
    }
}