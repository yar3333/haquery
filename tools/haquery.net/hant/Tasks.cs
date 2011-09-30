using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

//using hant.Log;

namespace haquery_net.hant
{
    class Tasks 
    {
        public delegate bool IncludeDelegate(string path);
        
        Log log;
        
        public Tasks(Log log)
        {
            this.log = log;
        }
        
        public List<String> findFiles(string path, IncludeDelegate include)
        {
            var r = new List<String>();
            
            foreach (var file in Directory.GetDirectories(path))
            {
                if (include(file))
                {
                    r.AddRange(findFiles(file, include));
                }
            }

            foreach (var file in Directory.GetFiles(path))
            {
                if (include(file))
                {
                    r.Add(file);
                }
            }
            
            return r;
        }
        
        public void createDirectory(string path)
        {
            log.start("Create directory '" + path + "'");
            try
            {
                var dirs = new List<string>(path.Split('\\'));
                for (var i=0; i<dirs.Count; i++)
                {
                    var dir = String.Join("\\", dirs.GetRange(0, i + 1).ToArray());
                    if (!dir.EndsWith(":"))
                    {
                        if (!Directory.Exists(dir))
                        {
                            Directory.CreateDirectory(dir);
                        }
                    }
                }
                log.finishOk();
            }
            catch (Exception e)
            {
                log.finishFail(e.Message);
            }
        }
        
        public void copyFolderContent(string fromFolder, string toFolder, IncludeDelegate include)
        {
            log.start("Copy directory '" + fromFolder + "' => '" + toFolder + "'");
            try
            {
                foreach (var file in Directory.GetDirectories(fromFolder))
                {
                    if (include(file))
                    {
                        copyFolderContent(file, toFolder + '\\' + Path.GetFileName(file), include);
                    }
                }
                
                foreach (var file in Directory.GetFiles(fromFolder))
                {
                    if (include(file))
                    {
                        if (!Directory.Exists(toFolder)) Directory.CreateDirectory(toFolder);

                        try
                        {
                            copyFile(file, toFolder + '\\' + Path.GetFileName(file));
                        }
                        catch (Exception e)
                        {
                            Console.WriteLine(e.Message);
                        }
                    }
                }
                log.finishOk();
            }
            catch (Exception e)
            {
                log.finishFail(e.Message);
            }
        }
        
        public void copyFile(string src, string dst)
        {
            log.start("Copy file '" + src + "' => '" + dst + "'");
            try
            {
                File.Copy(src, dst, true);
                log.finishOk();
            }
            catch (Exception e)
            {
                log.finishFail(e.Message);
            }
        }
        
        public void rename(string path, string newpath)
        {
            log.start("Rename '" + path + "' => '" + newpath + "'");
            try
            {
                if (File.Exists(path))
                {
                    if (File.Exists(newpath))
                    {
                        File.Delete(newpath);
                    }
                    File.Move(path, newpath);
                }
                else
                if (Directory.Exists(path))
                {
                    if (Directory.Exists(newpath))
                    {
                        Directory.Delete(newpath);
                    }
                    Directory.Move(path, newpath);
                }
                else
                {
                    throw new Exception("File '" + path + "' not found.");
                }
                log.finishOk();
            }
            catch (Exception e)
            {
                log.finishFail(e.Message);
            }
        }
        
        public void deleteDirectory(string path)
        {
            if (!Directory.Exists(path)) return;
            
            log.start("Delete directory '" + path + "'");
            try
            {
                foreach (var file in Directory.GetDirectories(path))
                {
                    deleteDirectory(file);
                }

                foreach (var file in Directory.GetFiles(path))
                {
                    deleteFile(file);
                }
                
                Directory.Delete(path);
                log.finishOk();
            }
            catch (Exception e)
            {
                log.finishFail(e.Message);
            }
        }
        
        public void deleteFile(string path)
        {
            log.start("Delete file '" + path + "'");
            try
            {
                File.Delete(path);
                log.finishOk();
            }
            catch (Exception e)
            {
                log.finishFail(e.Message);
            }
        }
        
        /*public string getWindowsRegistryValue(string:key)
        {
            var dir = neko.System.Environment.GetEnvironmentVariable("TMP");
		    if (dir == null)
            {
			    dir = "."; 		
            }
            var temp = dir + "/hant-tasks-get_windows_registry_value.txt";
		    if (neko.Sys.command('regedit /E "' + temp + '" "' + key + '"') != 0) 
            {
			    // might fail without appropriate rights
			    return null;
		    }
		    // it's possible that if registry access was disabled the proxy file is not created
		    var content = try neko.io.File.getContent(temp) catch ( e : Dynamic ) return null;
            content = content.Replace("\x00", "").Replace('\r', '').Replace('\\\\', '\\');
		    neko.FileSystem.deleteFile(temp);
            
            var re = new EReg('^@="(.*)"$', 'm');
            if (re.match(content)) return re.matched(1);
            
            return content;
        }*/
    }
}