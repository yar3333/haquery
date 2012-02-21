using System;
using System.Collections.Generic;
using System.IO;
using System.Diagnostics;

namespace runwaiter
{
    class Program
    {
        static int Main(string[] args)
        {
            if (args.Length >= 2)
            {
                int waitTime;
                try
                {
                    waitTime = int.Parse(args[0]);
                }
                catch (FormatException)
                {
                    return 1;
                }

                return runWaiter(waitTime, args[1], new List<String>(args).GetRange(2, args.Length - 2).ToArray());
            }
            else
            {
                Console.WriteLine("runwaiter utility to run the program and wait specified time (after this time process will be killed).");
                Console.WriteLine("Usage: runwaiter <wait_time_in_ms> <program> [<program_args>]");
                Console.WriteLine("Return codes:");
                Console.WriteLine("\t0 - success");
                Console.WriteLine("\t1 - arguments invalid or not specified");
                Console.WriteLine("\t2 - program not found");
                Console.WriteLine("\t3 - program was killed");
                return 1;
            }
        }

        static int runWaiter(int waitTime, string exePath, string[] args)
        {
            if (File.Exists(exePath))
            {
                var arguments = "";
                foreach (var arg in args)
                {
                    arguments += '"' + arg + '"' + ' ';
                }
                arguments = arguments.TrimEnd();

                var psi = new ProcessStartInfo(exePath, arguments);
                psi.UseShellExecute = false;
                var p = Process.Start(psi);
                if (!p.WaitForExit(waitTime))
                {
                    p.Kill();
                    return 3;
                }
                return 0;
            }
            else
            {
                Console.WriteLine("runwaiter program '" + exePath + "' not found.");
                return 2;
            }
        }
    }
}
