using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace copyfolder
{
    class Program
    {
        static int Main(string[] args)
        {
            if (args.Length == 2)
            {
                copyFolderContent(args[0].TrimEnd("/\\".ToCharArray()), args[1].TrimEnd("/\\".ToCharArray()));
                return 0;
            }
            else
            {
                Console.WriteLine("copyfolder utility to copy folder content.");
                Console.WriteLine("Usage: copyfolder <from_dir> <to_dir>");
                return 1;
            }
        }

        static void copyFolderContent(string fromFolder, string toFolder)
        {
            foreach (var dir in Directory.GetDirectories(fromFolder))
            {
                if (include(dir))
                {
                    copyFolderContent(dir, toFolder + '\\' + Path.GetFileName(dir));
                }
            }

            foreach (var file in Directory.GetFiles(fromFolder))
            {
                if (include(file))
                {
                    var destFile = toFolder + '\\' + Path.GetFileName(file);
                    if (!File.Exists(destFile) || File.GetLastWriteTime(file) > File.GetLastWriteTime(destFile))
                    {
                        if (!Directory.Exists(toFolder))
                        {
                            Directory.CreateDirectory(toFolder);
                        }
                        File.Copy(file, destFile, true);
                    }
                }
            }
        }

        static bool include(string path)
        {
            if (path.EndsWith(".hx"))
            {
                return false;
            }
            
            var excludeFiles = new string[] {
                "copyfolder.exe"
                ,"copyfolder.pdb"
                ,"copyfolder.exe.config"
                ,"HaxeEReg.hx"
                ,"HaxeStd.hx"
                ,"HaxeStringTools.hx"
                ,"library.hxproj"
                ,"restorefiletime.exe"
                ,"run.n"
                ,"runwaiter.exe"
                ,"runwaiter.pdb"
                ,"runwaiter.exe.config"
            };

            foreach (var f in excludeFiles)
            {
                if (path.EndsWith("\\" + f))
                {
                    return false;
                }
            }
            
            return true;
        }
    }
}
