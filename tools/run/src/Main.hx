package ;

import hant.PathTools;
import hant.Hant;
import neko.Lib;
import neko.Sys;
import hant.Log;
import haquery.server.HaqConfig;
import haquery.server.db.HaqDb;
import orm.OrmGenerator;
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
		var hant = new Hant(log, exeDir + "/" + "hant-" + Sys.systemName().toLowerCase());
		
        if (args.length > 0)
		{
			var command = args.shift();
			switch (command)
			{
				case 'gen-orm': 
					var project = new FlashDevelopProject("");
					var databaseConnectionString = args.length > 0 ? args[0] : new HaqConfig(project.srcPath + "config.xml").databaseConnectionString;
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
				
				case 'pre-build': 
					if (!(new Build(log, hant, exeDir).preBuild(
						  Lambda.has(args, "--no-gen-code")
						, Lambda.has(args, "--js-modern")
						, Lambda.has(args, "--dead-code-elimination")
					))) fail();
				
				case 'post-build': 
					if (!(new Build(log, hant, exeDir).postBuild())) fail();
				
				case 'gen-code': 
					if (!(new Build(log, hant, exeDir).genCode())) fail();
					
				case 'install':
					new Setup(log, hant, exeDir).install();
				
				default:
					fail("command '" + command + "' is not supported.");
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
			Lib.println("        pre-build                      Do pre-build step.");
			Lib.println("            [--no-gen-code]            Do not generate shared and another classes.");
			Lib.println("            [--js-modern]              Generate js code in modern style.");
			Lib.println("            [--dead-code-elimination]  For a while is not supported.");
			Lib.println("");
			Lib.println("        post-build                     Do post-build step.");
			Lib.println("");
			Lib.println("        gen-orm                        Generate object-related classes (managers and models).");
			Lib.println("            [databaseConnectionString] Like 'mysql://user:pass@host/dbname'.");
			Lib.println("");
			Lib.println("        gen-code                       Generate shared and another classes.");
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