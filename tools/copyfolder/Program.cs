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
            if (args.Length >= 2 && args.Length <= 4)
            {
                var platform = args.Length > 2 ? args[2] : null;
                Regex exclude = args.Length > 3 ? new Regex(args[3], RegexOptions.IgnoreCase) : null;
                var src = Path.GetFullPath(args[0]).TrimEnd("/\\".ToCharArray());
                var dest = args[1].TrimEnd("/\\".ToCharArray());
                copyFolderContent(src, dest, platform, exclude);
                return 0;
            }
            else
            {
                Console.WriteLine("copyfolder utility to copy folder content.");
                Console.WriteLine("Usage: copyfolder <from_dir> <to_dir> [<platform> [exclude_regular_exprerssion]]");
                return 1;
            }
        }

        static void copyFolderContent(string fromFolder, string toFolder, string platform, Regex exclude)
        {
            foreach (var dir in Directory.GetDirectories(fromFolder))
            {
                if (isAllowedForPlatform(dir, platform))
                {
                    if (exclude == null || !exclude.IsMatch(dir.Replace("\\", "/")))
                    {
                        copyFolderContent(dir, toFolder + '\\' + getDestFileName(dir, platform), platform, exclude);
                    }
                }
            }

            foreach (var file in Directory.GetFiles(fromFolder))
            {
                if (isAllowedForPlatform(file, platform))
                {
                    if (exclude == null || !exclude.IsMatch(file.Replace("\\", "/")))
                    {
                        var destFile = toFolder + '\\' + getDestFileName(file, platform);
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

        static bool isAllowedForPlatform(string path, string platform)
        {
            var name = GetFileNameWithoutExtension(path);
            return platform == null || !name.Contains("--") || name.EndsWith("--" + platform);
        }

        static string getDestFileName(string path, string platform)
        {
            var name = GetFileNameWithoutExtension(path);
            if (platform == null || !name.Contains("--"))
            {
                return name + GetExtension(path);
            }
            if (name.EndsWith("--" + platform))
            {
                return name.Substring(0, name.Length - ("--" + platform).Length) + GetExtension(path);
            }
            return null;
        }

        static string GetFileNameWithoutExtension(string path)
        {
            var name = Path.GetFileNameWithoutExtension(path);
            return name != "" ? name : Path.GetExtension(path);
        }
        
        static string GetExtension(string path)
        {
            var name = Path.GetFileNameWithoutExtension(path);
            return name != "" ? Path.GetExtension(path) : "";
        }
    }
}
