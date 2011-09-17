package hant;

import neko.FileSystem;
import neko.io.File;
import neko.Sys;

class Tasks 
{
    public function new()
    {
    }
    
    public function findFiles(path:String, include:String->Bool) : Array<String>
    {
        var r : Array<String> = new Array<String>();
        
        for (file in FileSystem.readDirectory(path))
        {
            trace(file);
            if (include(path + '/' + file))
            {
                if (FileSystem.isDirectory(path + '/' + file))
                {
                    r = r.concat(findFiles(path + '/' + file, include));
                }
                else
                {
                    r.push(path + '/' + file);
                }
            }
        }
        
        return r;
    }
    
    public function copyFolderContent(fromFolder:String, toFolder:String, include:String->Bool)
    {
        if (!FileSystem.exists(toFolder)) FileSystem.createDirectory(toFolder);
        
        for (file in FileSystem.readDirectory(fromFolder))
        {
            if (include(fromFolder + '/' + file))
            {
                if (FileSystem.isDirectory(fromFolder + '/' + file))
                {
                    copyFolderContent(fromFolder + '/' + file, toFolder + '/' + file, include);
                }
                else
                {
                    File.copy(fromFolder + '/' + file, toFolder + '/' + file);
                }
            }
        }
    }
}