package hant;

import neko.FileSystem;
import neko.io.File;
import neko.Sys;
using StringTools;

class Tasks 
{
    public function new()
    {
    }
    
    public function createDirectory(path:String)
    {
        path = path.replace('\\', '/');
        var dirs : Array<String> = path.split('/');
        for (i in 0...dirs.length)
        {
            var dir = dirs.slice(0, i + 1).join('/');
            if (!FileSystem.exists(dir))
            {
                FileSystem.createDirectory(dir);
            }
        }
    }
    
    public function findFiles(path:String, include:String->Bool) : Array<String>
    {
        var r : Array<String> = new Array<String>();
        
        for (file in FileSystem.readDirectory(path))
        {
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
                    if (!FileSystem.exists(toFolder)) createDirectory(toFolder);
                    File.copy(fromFolder + '/' + file, toFolder + '/' + file);
                }
            }
        }
    }
}