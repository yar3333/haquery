using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace restorefiletime
{
    class Program
    {
        static int Main(string[] args)
        {
            if (args.Length == 2)
            {
                restoreFileTime(args[0], args[1]);
                return 0;
            }
            else
            {
                Console.WriteLine("restorefiletime utility to restore last modified time of the files with the same names.");
                Console.WriteLine("Usage: restorefiletime <from_dir> <to_dir>");
                return 1;
            }
        }

        static void restoreFileTime(string fromPath, string toPath)
        {
            if (File.Exists(fromPath) && File.Exists(toPath))
            {
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
            }
            else
                if (Directory.Exists(fromPath) && Directory.Exists(toPath))
                {
                    foreach (var file in Directory.GetDirectories(fromPath))
                    {
                        restoreFileTime(file, toPath + '\\' + Path.GetFileName(file));
                    }

                    foreach (var file in Directory.GetFiles(fromPath))
                    {
                        if (file.EndsWith(".php") || file.EndsWith(".js"))
                        {
                            restoreFileTime(file, toPath + '\\' + Path.GetFileName(file));
                        }
                    }
                }
        }


    }
}
