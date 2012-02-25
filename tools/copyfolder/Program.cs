using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Text.RegularExpressions;

namespace copyfolder
{
    class Program
    {
        static int Main(string[] args)
        {
            if (args.Length == 2 || args.Length == 3)
            {
                Regex exclude = args.Length > 2 ? new Regex(args[2], RegexOptions.IgnoreCase) : null;
                copyFolderContent(args[0].TrimEnd("/\\".ToCharArray()), args[1].TrimEnd("/\\".ToCharArray()), exclude);
                return 0;
            }
            else
            {
                Console.WriteLine("copyfolder utility to copy folder content.");
                Console.WriteLine("Usage: copyfolder <from_dir> <to_dir> [exclude_regular_exprerssion]");
                return 1;
            }
        }

        static void copyFolderContent(string fromFolder, string toFolder, Regex exclude)
        {
            foreach (var dir in Directory.GetDirectories(fromFolder))
            {
                if (exclude == null || !exclude.IsMatch(dir.Replace("\\", "/")))
                {
                    copyFolderContent(dir, toFolder + '\\' + Path.GetFileName(dir), exclude);
                }
            }

            foreach (var file in Directory.GetFiles(fromFolder))
            {
                if (exclude == null || !exclude.IsMatch(file.Replace("\\", "/")))
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
    }
}
