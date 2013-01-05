package ;

import hant.CmdOptions;
import hant.PathTools;
import hant.FileSystemTools;
import haquery.Exception;
import neko.Lib;
import neko.Sys;
import hant.Log;
import haquery.server.HaqConfig;
import haquery.server.db.HaqDb;
import orm.OrmGenerator;
import haquery.common.HaqTemplateExceptions;
using StringTools;

class Main 
{
	static function main()
	{
		var exeDir = PathTools.path2normal(Sys.getCwd());
        
		var args = Sys.args();
		if (args.length > 0)
		{
			Sys.setCwd(args.pop());
		}
		else
		{
			fail("run this program via haxelib utility.");
		}
		
		var log = new Log(2);
		var fs = new FileSystemTools(log, exeDir + "/" + "hant-" + Sys.systemName().toLowerCase());
		
        if (args.length > 0)
		{
			var command = args.shift();
			
			try
			{
				switch (command)
				{
					case 'gen-orm': 
						var project = new FlashDevelopProject(log, "");
						var databaseConnectionString = args.length > 0 ? args[0] : HaqConfig.load(project.srcPath + "config.xml").databaseConnectionString;
						if (databaseConnectionString != null && databaseConnectionString != "")
						{
							log.start("Generate object related mapping classes");
								new OrmGenerator(log, project).generate(new HaqDb(databaseConnectionString));
							log.finishOk();
						}
						else
						{
							fail(
								  "databaseConnectionString not found.\n"
								+ "You may specify it in the 'src/config.xml' file:\n"
								+ "\t<config>\n"
								+ "\t\t<param name=\"databaseConnectionString\" value=\"mysql://USER:PASSWORD@HOST/DATABASE\" />\n"
								+ "\t</config>\n"
								+ "or in the command line:\n"
								+ "\thaxelib run HaQuery gen-orm mysql://USER:PASSWORD@HOST/DATABASE"
							);
						}
					
					case 'build': 
						var options = new CmdOptions();
						options.add("output", "bin", [ "--output" ]);
						options.add("noGenCode", false, [ "--no-gen-code" ]);
						options.add("jsModern", false, [ "--js-modern" ]);
						options.add("deadCodeElimination", false, [ "--dead-code-elimination" ]);
						options.add("noServer", false, [ "--no-server" ]);
						options.add("noClient", false, [ "--no-client" ]);
						options.add("mobile", false, [ "--mobile" ]);
						options.parse(args);
						new Build(log, fs, exeDir).build(
							  options.get("output")
							, options.get("noGenCode")
							, options.get("jsModern")
							, options.get("deadCodeElimination")
							, options.get("noServer")
							, options.get("noClient")
							, options.get("mobile")
						);
					
					case 'gen-code': 
						var options = new CmdOptions();
						options.add("mobile", false, [ "--mobile" ]);
						options.parse(args);
						new Build(log, fs, exeDir).genCode(options.get("mobile"));
						
					case 'install':
						new Setup(log, fs, exeDir).install();
					
					default:
						fail("command '" + command + "' is not supported.");
				}
			}
			catch (e:HaqTemplateNotFoundException)
			{
				log.trace("ERROR: component not found [ " + e.toString() + " ].");
				fail();
			}
			catch (e:HaqTemplateRecursiveExtendsException)
			{
				log.trace("ERROR: recursive extend detected [ " + e.toString() + " ].");
				fail();
			}
			catch (e:Exception)
			{
				log.trace(e.message);
				fail();
			}
        }
		else
		{
			Lib.println("HaQuery building support and deploying tool.");
			Lib.println("Usage: haxelib run HaQuery <command>");
			Lib.println("");
			Lib.println("    where <command> may be:");
			Lib.println("");
			Lib.println("        install                        Install FlashDevelop templates.");
			Lib.println("");
			Lib.println("        build                          Do project building.");
			Lib.println("            [--output=<dir>]           Output folder (by default is 'bin').");
			Lib.println("            [--no-gen-code]            Do not generate shared and another classes.");
			Lib.println("            [--js-modern]              Generate js code in modern style.");
			Lib.println("            [--dead-code-elimination]  For a while is not supported.");
			Lib.println("            [--no-server]              Skip server compilation.");
			Lib.println("            [--no-client]              Skip client compilation.");
			Lib.println("            [--mobile]                 Generate html pages for using with Cordova.");
			Lib.println("                                       Definition 'mobile' will be defined too.");
			Lib.println("");
			Lib.println("        gen-orm                        Generate object-related classes.");
			Lib.println("            [databaseConnectionString] Like 'mysql://user:pass@host/dbname'.");
			Lib.println("");
			Lib.println("        gen-code                       Generate shared and another classes.");
			Lib.println("            [--mobile]                 Define 'mobile' while preprocessing.");
		}
        
        Sys.exit(0);
	}
	
	static function fail(?message:String)
	{
		if (message != null)
		{
			Lib.println("ERROR: " + message);
		}
		Sys.exit(1);
	}
}