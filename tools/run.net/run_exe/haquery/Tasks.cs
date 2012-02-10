using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using ICSharpCode.SharpZipLib.Zip;

namespace run_exe.haquery
{
    class Tasks 
    {
        hant.Log log;
        hant.Tasks hant;
        FastZip fastZip;
        
        public Tasks()
        {
            log = new hant.Log(2);
            hant = new hant.Tasks(log);
            fastZip = new FastZip();
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
            if (path == getExeDir() + "\\tools") return false;
            
            if (Directory.Exists(path))
            {
                return !path.EndsWith(".svn");
            }
            return path.EndsWith("\\Server.hx") || path.EndsWith("\\Bootstrap.hx");
        }
        
        bool isClientFile(string path)
        {
            if (path == getExeDir() + "\\tools") return false;
            
            if (Directory.Exists(path))
            {
                return !path.EndsWith(".svn");
            }
            return path.EndsWith("\\Client.hx");
        }

        bool isSupportFile(string path)
        {
            if (path == getExeDir() + "\\tools"
             || path == getExeDir() + "\\run.n"
             || path == getExeDir() + "\\run.exe"
             || path == getExeDir() + "\\run.exe.config"
             || path == getExeDir() + "\\run.pdb"
             || path == getExeDir() + "\\ICSharpCode.SharpZipLib.dll"
             || path == getExeDir() + "\\readme.txt"
             || path == getExeDir() + "\\haxelib.xml"
            ) return false;
            
            if (Directory.Exists(path))
            {
                return !path.EndsWith(".svn");
            }
            return !path.EndsWith(".hx") && !path.EndsWith(".hxproj");
        }

        bool isSupportFileWithoutComponents(string path)
        {
            if (isSupportFile(path))
            {
                return path != getExeDir() + "\\haquery\\components";
            }
            return false;
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

            r.Add(getExeDir());

            foreach (var file in Directory.GetFiles("."))
            {
                if (file.EndsWith(".hxproj"))
                {
                    var xml = new System.Xml.XmlDocument();
                    xml.Load(file);
                    foreach (System.Xml.XmlElement elem in xml.SelectNodes("/project/classpaths/class"))
                    {
                        if (elem.HasAttribute("path"))
                        {
                            r.Add(elem.GetAttribute("path"));
                        }
                    }
                }
            }
            
            return r;
        }

        string getBinPath()
        {
            foreach (var file in Directory.GetFiles("."))
            {
                if (file.EndsWith(".hxproj"))
                {
                    var xml = new System.Xml.XmlDocument();
                    xml.Load(file);
                    foreach (System.Xml.XmlElement elem in xml.SelectNodes("/project/output/movie"))
                    {
                        if (elem.HasAttribute("path"))
                        {
                            return elem.GetAttribute("path").TrimEnd("\\/".ToCharArray());
                        }
                    }
                }
            }
            
            return "bin";
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

            try
            {
                System.Diagnostics.ProcessStartInfo psi = new System.Diagnostics.ProcessStartInfo(fileName, arguments);
                psi.UseShellExecute = false;
                var p = System.Diagnostics.Process.Start(psi);
                p.WaitForExit();
            }
            catch (System.ComponentModel.Win32Exception e)
            {
                Console.WriteLine("Error: file '" + fileName + "' not found. Maybe you need to add directory to the PATH system environment variable.");
                throw e;
            }
        }
        
        void buildJs()
        {
            var binPath = getBinPath();

            log.start("Build client to '" + binPath + "\\haquery\\client\\haquery.js'");

            if (File.Exists(binPath + "\\haquery\\client\\haquery.js"))
            {
                hant.rename(binPath + "\\haquery\\client\\haquery.js", binPath + "\\haquery\\client\\haquery.js.old");
            }

            hant.createDirectory(binPath + "\\haquery\\client");
            
            var pars = new List<String>();
            foreach (var path in getClassPaths())
            {
                pars.Add("-cp"); pars.Add(path);
            }
            pars.Add("-lib"); pars.Add("HaQuery");
            pars.Add("-js");
            pars.Add(binPath + "\\haquery\\client\\haquery.js");
            pars.Add("-main"); pars.Add("Main");
            pars.Add("-debug");
            run("haxe", pars.ToArray());

            if (File.Exists(binPath + "\\haquery\\client\\haquery.js")
             && File.Exists(binPath + "\\haquery\\client\\haquery.js.old"))
            {
                restoreFileTimes(binPath + "\\haquery\\client\\haquery.js.old", "" + binPath + "\\haquery\\client\\haquery.js");
                hant.deleteFile(binPath + "\\haquery\\client\\haquery.js.old");
            }
            
            log.finishOk();
        }

        string getExeDir()
        {
            System.Reflection.Assembly a = System.Reflection.Assembly.GetEntryAssembly();
            return System.IO.Path.GetDirectoryName(a.Location);
        }
        
        public void genOrm(string databaseConnectionString)
        {
            log.start("Generate object related mapping classes");

            run("php", new string[] { getExeDir() + "\\tools\\orm\\index.php", databaseConnectionString, "src" });
            
            log.finishOk();
        }

        public void genTrm(string componentsPackage)
        {
            log.start("Generate template related mapping classes");

            run("php", new string[] { getExeDir() + "\\tools\\trm\\index.php", componentsPackage });
            
            log.finishOk();
        }
        
        public void preBuild()
        {
            log.start("Do pre-build step");
            
            genImports();
            try { saveLibFolder(); } catch { }
            
            log.finishOk();
        }

        void saveLibFolder()
        {
            var binPath = getBinPath();

            log.start("Save " + binPath + "\\lib folder");

            if (Directory.Exists(binPath + "\\lib"))
            {
                hant.deleteDirectory(binPath + "\\lib.old");
                hant.rename(binPath + "\\lib", binPath + "\\lib.old");
            }

            log.finishOk();
        }

        void loadLibFolder()
        {
            var binPath = getBinPath();
            
            log.start("Load file times to " + binPath + "\\lib");

            if (Directory.Exists(binPath + "\\lib"))
            {
                restoreFileTimes(binPath + "\\lib.old", binPath + "\\lib");
                hant.deleteDirectory(binPath + "\\lib.old");
            }

            log.finishOk();
        }

        public void postBuild(bool skipJS, bool skipComponents)
        {
            log.start("Do post-build step");

            if (!skipJS)
            {
                buildJs();
            }

            foreach (var path in getClassPaths())
            {
                hant.copyFolderContent(path, getBinPath(), !skipComponents ? new hant.Tasks.IncludeDelegate(isSupportFile) : new hant.Tasks.IncludeDelegate(isSupportFileWithoutComponents));
            }

            loadLibFolder();
            
            log.finishOk();
        }

        void restoreFileTimes(string fromPath, string toPath)
        {
            if (File.Exists(fromPath) && File.Exists(toPath))
            {
                log.start("Restore file time '" + fromPath + "' => '" + toPath + "'");
                try
                {
                    if (File.ReadAllText(fromPath) == File.ReadAllText(toPath))
                    {
                        File.SetLastWriteTime(toPath, File.GetLastWriteTime(fromPath));
                    }
                }
                catch (Exception e)
                {
                    Console.WriteLine(e.Message);
                }
                log.finishOk();
            }
            else
            if (Directory.Exists(fromPath) && Directory.Exists(toPath))
            {
                log.start("Restore files time '" + fromPath + "' => '" + toPath + "'");
                foreach (var file in Directory.GetDirectories(fromPath))
                {
                    restoreFileTimes(file, toPath + '\\' + Path.GetFileName(file));
                }

                foreach (var file in Directory.GetFiles(fromPath))
                {
                    if (file.EndsWith(".php") || file.EndsWith(".js"))
                    {
                        restoreFileTimes(file, toPath + '\\' + Path.GetFileName(file));
                    }
                }
                log.finishOk();
            }
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

            var srcPath = getExeDir() + "\\tools\\flashdevelop.zip";
            var userLocalPath = System.Environment.GetEnvironmentVariable("LOCALAPPDATA") != null
                ? System.Environment.GetEnvironmentVariable("LOCALAPPDATA")
                : System.Environment.GetEnvironmentVariable("USERPROFILE") + "\\Local Settings\\Application Data";
            var flashDevelopUserDataPath = userLocalPath + "\\FlashDevelop";

            fastZip.ExtractZip(srcPath, flashDevelopUserDataPath, null);

            log.finishOk();
        }
        
        void installHaxeMod()
        {
            log.start("Install HaxeMod");
            
            var haxePath = getHaxePath();
            if (!Directory.Exists(haxePath + "std.original"))
            {
                hant.rename(haxePath + "std", haxePath + "std.original");
                
                var destPath = haxePath + "std";
                Directory.CreateDirectory(destPath);
                fastZip.ExtractZip(getExeDir() + "\\tools\\haxemod.zip", destPath, null);
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
                uninstallFlashDevelopTemplates();
                uninstallHaxeMod();
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
                Console.WriteLine("HaQuery uninstallation was aborted. Ensure what you run this program under administrator account.");
            }
        }
        
        void uninstallFlashDevelopTemplates()
        {
            //log.start('Uninstall FlashDevelop templates');
            
            //log.finishOk();
        }
        
        void uninstallHaxeMod()
        {
            log.start("Uninstall HaxeMod");
            
            var haxePath = getHaxePath();
            
            if (Directory.Exists(haxePath + "std.original"))
            {
                hant.deleteDirectory(haxePath + "std");
                hant.rename(haxePath + "std.original", haxePath + "std");
            }
            
            log.finishOk();
        }
        
        
    }
}