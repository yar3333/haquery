using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace run_exe.haquery
{
    class Tasks 
    {
        hant.Log log;
        hant.Tasks hant;
        
        public Tasks()
        {
            log = new hant.Log(2);
            hant = new hant.Tasks(log);
        }
        
        void genImports()
        {
            log.start("Generate imports to 'src\\Imports.hx'");
            
            
            var fo = new StreamWriter(new System.IO.FileStream("src\\Imports.hx", System.IO.FileMode.Create));
            
            foreach (var path in getClassPaths())
            {
                fo.Write("// " + path + "\n");
                genImportsInner(fo, path);
                fo.Write("\n");
            }
            
            fo.Close();
            
            log.finishOk();
        }
        
        void genImportsInner(System.IO.TextWriter fo, string srcPath)
        {
            var serverImports = hant.findFiles(srcPath, isServerFile);
            var clientImports = hant.findFiles(srcPath, isClientFile);
            
            fo.WriteLine("#if php");
            foreach (var file in serverImports) fo.WriteLine(file2import(srcPath, file));
            fo.WriteLine("#else");
            foreach (var file in clientImports) fo.WriteLine(file2import(srcPath, file));
            fo.WriteLine("#end");
        }
        
        bool isServerFile(string path)
        {
            if (Directory.Exists(path))
            {
                return !path.EndsWith(".svn");
            }
            return path.EndsWith("\\Server.hx") || path.EndsWith("\\Bootstrap.hx");
        }
        
        bool isClientFile(string path)
        {
            if (Directory.Exists(path))
            {
                return !path.EndsWith(".svn");
            }
            return path.EndsWith("\\Client.hx");
        }

        bool isHaQuerySupportFile(string path)
        {
            if (Directory.Exists(path) && path == "tools") return false;
            return isSupportFile(path);
        }
        
        bool isSupportFile(string path)
        {
            if (Directory.Exists(path))
            {
                return !path.EndsWith(".svn") && path != "tools";
            }
            return !path.EndsWith(".hx") && !path.EndsWith(".hxproj");
        }
        
        string file2import(string basePath, string file)
        {
            if (file.StartsWith(basePath))
            {
                file = file.Substring(basePath.Length + 1);
            }

            return "import " + Path.GetDirectoryName(file).Replace('\\', '.') + "." + Path.GetFileNameWithoutExtension(file) + ';';
        }
        
        bool isNotSvn(string path)
        {
            if (Directory.Exists(path))
            {
                return !path.EndsWith(".svn");
            }
            return true;
        }
        
        public List<string> getClassPaths()
        {
            var r = new List<String>();
            var files = Directory.GetFiles(".");
            foreach (var file in files)
            {
                if (file.EndsWith(".hxproj"))
                {
                    var xml = new System.Xml.XmlDocument();
                    xml.Load(file);
                    foreach (System.Xml.XmlElement elem in xml.SelectNodes("/project/classpaths/class"))
                    {
                        if (elem.GetAttribute("path") != null)
                        {
                            r.Add(elem.GetAttribute("path"));
                        }
                    }
                }
            }
            return r;
        }
        
        // -------------------------------------------------------------------------------

        void run(string fileName, string[] args)
        {
            var arguments = "";
            foreach (var arg in args)
            {
                arguments += '"' + arg + '"' + ' ';
            }
            arguments = arguments.TrimEnd();
            
            System.Diagnostics.ProcessStartInfo psi = new System.Diagnostics.ProcessStartInfo(fileName, arguments);
            psi.UseShellExecute = false;
            var p = System.Diagnostics.Process.Start(psi);
            p.WaitForExit();
        }
        
        void buildJs()
        {
            log.start("Build client to 'bin\\haquery\\client\\haquery.js'");
            
            hant.createDirectory("bin\\haquery\\client");
            
            var pars = new List<String>();
            foreach (var path in getClassPaths())
            {
                pars.Add("-cp"); pars.Add(path);
            }
            pars.Add("-lib"); pars.Add("HaQuery");
            pars.Add("-js");
            pars.Add("bin\\haquery\\client\\haquery.js");
            pars.Add("-main"); pars.Add("Main");
            pars.Add("-debug");
            run("haxe", pars.ToArray());
            
            log.finishOk();
        }

        string getExeDir()
        {
            System.Reflection.Assembly a = System.Reflection.Assembly.GetEntryAssembly();
            return System.IO.Path.GetDirectoryName(a.Location);
        }
        
        public void genOrm(string databaseConnectionString)
        {
            log.start("Generate ORM classes to 'models'");

            run("php", new string[] { getExeDir() + "\\tools\\orm\\index.php", databaseConnectionString, "src" });
            
            log.finishOk();
        }
        
        public void preBuild()
        {
            log.start("Do pre-build step");
            
            genImports();
            saveLibFolder();
            
            log.finishOk();
        }

        void saveLibFolder()
        {
            log.start("Save bin\\lib folder");

            if (Directory.Exists("bin\\lib"))
            {
                hant.deleteDirectory("bin\\lib.old");
                hant.rename("bin\\lib", "bin\\lib.old");
            }

            log.finishOk();
        }

        void loadLibFolder()
        {
            log.start("Load file times to bin\\lib");

            restoreFileTimes("bin\\lib.old", "bin\\lib");
            hant.deleteDirectory("bin\\lib.old");

            log.finishOk();
        }
        
        public void postBuild()
        {
            log.start("Do post-build step");
            
            buildJs();

            hant.copyFolderContent(getExeDir(), "bin", isHaQuerySupportFile);
            
            foreach (var path in getClassPaths())
            {
                hant.copyFolderContent(path, "bin", isSupportFile);
            }

            loadLibFolder();
            
            log.finishOk();
        }

        void restoreFileTimes(string fromFolder, string toFolder)
        {
            if (!Directory.Exists(fromFolder)) return;
            if (!Directory.Exists(toFolder)) return;
            
            log.start("Restore files time '" + fromFolder + "' => '" + toFolder + "'");
            
            foreach (var file in Directory.GetDirectories(fromFolder))
            {
                restoreFileTimes(file, toFolder + '\\' + Path.GetFileName(file));
            }

            foreach (var file in Directory.GetFiles(fromFolder))
            {
                if (file.EndsWith(".php") || file.EndsWith(".js"))
                {
                    try
                    {
                        var toFile = toFolder + '\\' + Path.GetFileName(file);
                        if (File.ReadAllText(file) == File.ReadAllText(toFile))
                        {
                            File.SetLastWriteTime(toFile, File.GetLastWriteTime(file));
                        }
                    }
                    catch (Exception e)
                    {
                        Console.WriteLine(e.Message);
                    }
                }
            }
            
            log.finishOk();
        }
        
        public string getHaxePath()
        {
            var r = System.Environment.GetEnvironmentVariable("HAXEPATH");
            
            if (r == null)
            {
                throw new Exception("HaXe not found (HAXEPATH environment variable not set).");
            }

            r = r.TrimEnd('\\') + '\\';
            
            if (!File.Exists(r + "haxe.exe"))
            {
                throw new Exception("HaXe not found (file '" + r + "haxe.exe' do not exist).");
            }
            
            return r;
        }
        
        public void install()
        {
            try
            {
                installFlashDevelopTemplates();
                installHaxeMod();
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
                Console.WriteLine("HaQuery installation to the system was aborted. Ensure what you run this program under administrator account.");
            }
        }
        
        void installFlashDevelopTemplates()
        {
            log.start("Install FlashDevelop templates");

            var srcPath = getExeDir() + "\\tools\\flashdevelop";
            var haxePath = getHaxePath();
            var userLocalPath = System.Environment.GetEnvironmentVariable("LOCALAPPDATA") != null
                ? System.Environment.GetEnvironmentVariable("LOCALAPPDATA")
                : System.Environment.GetEnvironmentVariable("USERPROFILE") + "\\Local Settings\\Application Data";
            var flashDevelopUserDataPath = userLocalPath + "\\FlashDevelop";
            hant.copyFolderContent(srcPath, flashDevelopUserDataPath, isNotSvn);

            /*var projectFilePath = flashDevelopUserDataPath + "\\Projects\\380 HaXe - HaQuery Project\\Project.hxproj";
            var projectFileContent = File.ReadAllText(projectFilePath);
            File.WriteAllText(projectFilePath, projectFileContent.Replace("{HaQuerySrcPath}", Path.GetFullPath(getExeDir() + "\\..\\src")));*/

            log.finishOk();
        }
        
        void installHaxeMod()
        {
            log.start("Install HaxeMod");
            
            var haxePath = getHaxePath();

            /*if (!Directory.Exists(haxePath + 'haxe.exe.original'))
            {
                hant.rename(haxePath + 'haxe.exe', haxePath + 'haxe.exe.original');
            }
            File.Copy(getExeDir() + '\\tools\\haxemod\\haxe.exe', haxePath + 'haxe.exe');*/

            if (!Directory.Exists(haxePath + "std.original"))
            {
                hant.rename(haxePath + "std", haxePath + "std.original");
                hant.copyFolderContent(getExeDir() + "\\tools\\haxemod\\std", haxePath + "std", new hant.Tasks.IncludeDelegate(getTrue));
            }
            
            log.finishOk();
        }

        static bool getTrue(string path)
        {
            return true;
        }
        
        public void uninstall()
        {
            try
            {
                //uninstallFlashDevelopTemplates();
                uninstallHaxeMod();
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
                Console.WriteLine("HaQuery uninstallation was aborted. Ensure what you run this program under administrator account.");
            }
        }
        
        /*function uninstallFlashDevelopTemplates()
        {
            log.start('Uninstall FlashDevelop templates');
            
            log.finishOk();
        }*/
        
        void uninstallHaxeMod()
        {
            log.start("Uninstall HaxeMod");
            
            var haxePath = getHaxePath();

            /*if (!Directory.Exists(haxePath + 'haxe.exe.original'))
            {
                log.finishFail("HaxeMod does not installed.");
            }
            hant.rename(haxePath + 'haxe.exe.original', haxePath + 'haxe.exe');*/
            
            if (Directory.Exists(haxePath + "std.original"))
            {
                hant.deleteDirectory(haxePath + "std");
                hant.rename(haxePath + "std.original", haxePath + "std");
            }
            
            log.finishOk();
        }
        
        
    }
}