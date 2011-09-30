using System;
using System.Collections.Generic;
using System.Text;

namespace haquery_net
{
    class Program
    {
        static int Main(string[] args)
        {
            var haquery = new haquery.Tasks();
            
            switch (args.Length > 0 ? args[0] : "")
            {
                case "gen-orm": 
                    haquery.genOrm(args[1]);
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
                    Console.WriteLine("\t where <command> may be:");
                    Console.WriteLine("\t\tgen-orm <databaseConnectionString>    Generate tables-related classes to model folder.");
                    Console.WriteLine("\t\tpre-build                             Do pre-build step.");
                    Console.WriteLine("\t\tpost-build                            Do post-build step.");
                    Console.WriteLine("\t\tinstall                               Replace official haxe.exe and librarires to HaxeMod.");
                    Console.WriteLine("\t\tuninstall                             Restore official haxe.exe and libraries.");
                    return 1;
            }
            
            return 0;
        }
    }
}
