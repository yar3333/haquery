using System;
using System.Collections.Generic;
using System.Text;

namespace run_exe
{
    class Program
    {
        static int Main(string[] args)
        {
            var haquery = new haquery.Tasks();
            
            switch (args.Length > 0 ? args[0] : "")
            {
                case "gen-orm":
                    if (args.Length > 1)
                    {
                        haquery.genOrm(args[1]);
                    }
                    else
                    {
                        Console.WriteLine("Database connection string must be specified (mysql://USER:PASSWORD@HOST/DATABASE).");
                        return 1;
                    }
                    break;
                
                case "pre-build": 
                    haquery.preBuild();
                    break;
                
                case "post-build": 
                    haquery.postBuild();
                    break;
                    
                case "install":
                    haquery.install();
                    break;
                
                case "uninstall":
                    haquery.uninstall();
                    break;
                
                default:
                    
                    Console.WriteLine("HaQuery building support and deploying tool.");
                    Console.WriteLine("Usage: haquery <command>");
                    Console.WriteLine("\twhere <command> may be:");
                    Console.WriteLine("\t\tgen-orm <databaseConnectionString>    Generate tables-related classes to manager and model folders");
                    Console.WriteLine("\t\tpre-build                             Do pre-build step");
                    Console.WriteLine("\t\tpost-build                            Do post-build step");
                    Console.WriteLine("\t\tinstall                               Patch haXe librarires to HaxeMod");
                    Console.WriteLine("\t\tuninstall                             Restore original haXe libraries");
                    return 1;
            }
            
            return 0;
        }
    }
}
