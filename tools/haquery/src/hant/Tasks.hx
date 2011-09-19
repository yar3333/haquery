package hant;

import neko.FileSystem;
import neko.io.File;
import neko.Sys;
import neko.Lib;
using StringTools;

class Tasks 
{
    var log : Log;
    
    public function new(log:Log)
    {
        this.log = log;
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
    
    public function createDirectory(path:String)
    {
        log.start("Create directory '" + path + "'");
        try
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
            log.finishOk();
        }
        catch (message:String)
        {
            log.finishFail(message);
        }
    }
    
    public function copyFolderContent(fromFolder:String, toFolder:String, include:String->Bool)
    {
        log.start("Copy directory '" + fromFolder + "' => '" + toFolder + "'");
        try
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
                        
                        try
                        {
                            copyFile(fromFolder + '/' + file, toFolder + '/' + file);
                        }
                        catch (message:String)
                        {
                            Lib.println(message);
                        }
                    }
                }
            }
            log.finishOk();
        }
        catch (message:String)
        {
            log.finishFail(message);
        }
    }
    
    public function copyFile(src:String, dst:String)
    {
        log.start("Copy file '" + src + "' => '" + dst + "'");
        try
        {
            File.copy(src, dst);
            log.finishOk();
        }
        catch (message:String)
        {
            log.finishFail(message);
        }
    }
    
    public function rename(path:String, newpath:String)
    {
        log.start("Rename '" + path + "' => '" + newpath + "'");
        try
        {
            if (FileSystem.exists(path))
            {
                if (FileSystem.exists(newpath))
                {
                    FileSystem.deleteFile(newpath);
                }
                FileSystem.rename(path, newpath);
            }
            else
            {
                throw "File '" + path + "' not found.";
            }
            log.finishOk();
        }
        catch (message:String)
        {
            log.finishFail(message);
        }
    }
    
    public function deleteDirectory(path:String)
    {
        log.start("Delete directory '" + path + "'");
        try
        {
            FileSystem.deleteDirectory(path);
            log.finishOk();
        }
        catch (message:String)
        {
            log.finishFail(message);
        }
    }
}