package ;

import haquery.server.HaqConfig;
import haquery.tools.FlashDevelopProject;
import neko.Lib;
import neko.Sys;
import haquery.tools.Tasks;

class Main 
{
	static function main()
	{
		var exeDir = Sys.getCwd();
        
		var args = Sys.args();
		if (args.length > 0)
		{
			Sys.setCwd(args.pop());
		}
		else
		{
			Lib.println("To run this program use haxelib utility.");
			Sys.exit(1);
		}
		
		var exitCode = 0;
		
		var tasks = new Tasks(exeDir);
        
        if (args.length > 0)
		{
			var command = args.shift();
			switch (command)
			{
				case 'gen-orm': 
					var project = new FlashDevelopProject("", exeDir);
					var databaseConnectionString = args.length > 1 ? args[1] : new HaqConfig(project.srcPath + "config.xml").databaseConnectionString;
					if (databaseConnectionString != null && databaseConnectionString != "")
					{
						tasks.genOrm(databaseConnectionString, project);
					}
					else
					{
						Lib.println("ERROR: databaseConnectionString not found.");
						Lib.println("You may specify it in the 'src/config.xml' file:");
						Lib.println("\t<config>");
						Lib.println("\t\t<param name=\"databaseConnectionString\" value=\"mysql://USER:PASSWORD@HOST/DATABASE\" />");
						Lib.println("\t</config>");
						Lib.println("or in the command line:");
						Lib.println("\thaxelib run HaQuery gen-orm mysql://USER:PASSWORD@HOST/DATABASE");
						exitCode = 1;
					}
				
				case 'pre-build': 
					exitCode = tasks.preBuild() ? 0 : 1;
				
				case 'post-build': 
					exitCode = tasks.postBuild(Lambda.has(args, "--js-modern"), Lambda.has(args, "--dead-code-elimination")) ? 0 : 1;
					
				case 'install':
					tasks.install();
				
				default:
					Lib.println("ERROR: command '" + command + "' is not supported.");
					exitCode = 1;
			}
        }
		else
		{
			Lib.println("HaQuery building support and deploying tool.");
			Lib.println("Usage: haxelib run HaQuery <command>");
			Lib.println("\twhere <command> may be:");
			Lib.println("\t\tpre-build                      Do pre-build step.");
			Lib.println("\t\tpost-build                     Do post-build step.");
			Lib.println("\t\t\t[--js-modern]");
			Lib.println("\t\t\t[--dead-code-elimination]");
			Lib.println("\t\tinstall                        Install FlashDevelop templates.");
			Lib.println("\t\tgen-orm                        Generate object-related classes (managers and models).");
			Lib.println("\t\t\t[databaseConnectionString]");
			exitCode = 1;
		}
        
        Sys.exit(exitCode);
	}
}