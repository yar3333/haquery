package ;

import hant.CmdOptions;
import hant.FlashDevelopProject;
import hant.PathTools;
import hant.FileSystemTools;
import hant.Process;
import stdlib.Exception;
import neko.Lib;
import hant.Log;
import haquery.server.HaqConfig;
import haquery.common.HaqTemplateExceptions;
using StringTools;

typedef Command =
{
	var name : String;
	var description : String;
	var options : CmdOptions;
	var run : Void->Void;
}

class Main 
{
	static function main()
	{
		var exeDir = PathTools.normalize(Sys.getCwd());
        
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
		var fs = new FileSystemTools(log);
		
		var commands = getCommands(log, fs, exeDir);
		
		if (args.length > 0)
		{
			var commandName = args.shift();
			
			var command : Command = null;
			for (c in commands) if (c.name == commandName) { command = c; break; }
			
			if (command != null)
			{
				command.options.parse(args);
				
				try
				{
					command.run();
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
				catch (e:Dynamic)
				{
					log.trace(Std.string(e));
					fail();
				}
			}
			else
			{
				fail("command '" + commandName + "' is not supported.");
			}
        }
		else
		{
			Lib.println("HaQuery building support and deploying tool.");
			Lib.println("Usage: haxelib run HaQuery <command> [<command_options>]");
			Lib.println("");
			Lib.println("    where <command> and <command_options> may be:");
			Lib.println("");
			
			for (command in commands)
			{
				Lib.println("        " + StringTools.rpad(command.name, " ", 16) + command.description + "\n");
				var help = command.options.getHelpMessage("            ").rtrim();
				if (help != "") Lib.println(help + "\n");
			}
		}
        
        Sys.exit(0);
	}
	
	
	static function getCommands(log:Log, fs:FileSystemTools, exeDir:String) : Array<Command>
	{
		var r = new Array<Command>();
		
		{
			var name = "install";
			var description = "Install FlashDevelop templates.";
			var options = new CmdOptions();
			var run = function() : Void
			{
				new Setup(log, fs, exeDir).install();
			};
			r.push( { name:name, description:description, options:options, run:run } );
		}
		
		{
			var name = "build";
			var description = "Do project building.";
			
			var options = new CmdOptions();
			options.add("output", "bin", [ "--output" ], "Output folder (default is 'bin').");
			options.addRepeatable("classPaths", String, [ "-cp" ], "Specify class path.");
			options.addRepeatable("libs", String, [ "-lib" ], "Specify haxe library.");
			options.addRepeatable("defines", String, [ "-D" ], "Specify compiler define.");
			options.addRepeatable("haxeOptions", String, [ "-ho", "--haxe-option" ], "Specify haxe compiler option.");
			options.add("basePage", "", [ "--base-page" ], "Default base page. For example: 'pages.layout'. Default is 'haquery.(client/server).BasePage'.");
			options.add("staticUrlPrefix", "", [ "--static-url-prefix" ], "Prefix for URLs started with '~',\nlinks to system the system files\nand registered js/css files.\nAffected to HTML and CSS output only,\nnot to physical folders structure.");
			options.addRepeatable("htmlSubstitutes", String, [ "--html-substitute" ], "Regular expression to find and replace in html templates.");
			options.addRepeatable("onlyPagesPackage", String, [ "--only-pages-package" ], "Pages package to compile. If not specified then all pages will be compiled.");
			options.addRepeatable("ignorePages", String, [ "--ignore-pages" ], "Path to the page files to ignore.");
			options.add("port", 0, [ "--port" ], "Use haxe compiler server on specified port. Run server if it not running.");
			options.add("platform", "", [ "-p", "--platform" ], "Target server platform ('php' or 'neko'). Default is 'neko'.");
			options.add("project", "", null, "FlashDevelop project file to read.\n(Default: find *.hxproj in the current directory.)");
			
			var run = function() : Void
			{
				var project = FlashDevelopProject.load(options.get("project"));
				if (project != null)
				{
					project.binPath = options.get("output");
					project.classPaths = project.classPaths.concat(options.get("classPaths"));
					project.addLibs(options.get("libs"));
					project.directives = project.directives.concat(options.get("defines"));
					project.additionalCompilerOptions = project.additionalCompilerOptions.concat(options.get("haxeOptions"));
					if (options.get("platform") != "") project.platform = options.get("platform");
				}
				else
				{
					project = new FlashDevelopProject
					(
						null,
						options.get("output"),
						options.get("classPaths"),
						options.get("libs"),
						false, 
						options.get("platform") != "" ? options.get("platform") : "neko",
						options.get("haxeOptions"),
						options.get("defines")
					);
				}
				
				new Build(log, fs, project, options.get("port")).build
				(
					  options.get("basePage")
					, options.get("staticUrlPrefix")
					, options.get("htmlSubstitutes")
					, options.get("onlyPagesPackage")
					, options.get("ignorePages")
				);
			};
			r.push( { name:name, description:description, options:options, run:run } );
		}
		
		{
			var name = "orm";
			var description = "Call 'orm' haxe library to generate database-related classes.";
			
			var options = new CmdOptions();
			options.add("databaseConnectionString", "", null, "Database connecting string like 'mysql://user:pass@localhost/mydb'.\nRead from config.xml custom 'databaseConnectionString' node if not specified.");
			options.add("hxproj", "", [ "-p", "--hxproj" ], "Path to the FlashDevelop *.hxproj file.\nUsed to detect class paths.\nIf not specified then *.hxproj from the current folder will be used.");
			options.add("srcPath", "", [ "-s", "--src-path" ], "Path to your source files directory.\nThis is a base path for generated files.\nUsed last classpath from the project file if not specified.\nIf project file not found used 'src'.");
			
			var run = function() : Void
			{
				var project = FlashDevelopProject.load(options.get("hxproj"));
				var srcPath = PathTools.normalize(options.get("srcPath") != "" ? options.get("srcPath") : (project != null && project.classPaths.length > 0 ? project.classPaths[project.classPaths.length - 1] : "src"));
				var databaseConnectionString = options.get("databaseConnectionString") != "" 
					? options.get("databaseConnectionString") 
					: HaqConfig.load(srcPath + "/config.xml").customs.get("databaseConnectionString");
				if (databaseConnectionString != null && databaseConnectionString != "")
				{
					var params =
					[ 
						  "run", "orm"
						, databaseConnectionString
						, "-a", "models.server.autogenerated"
						, "-c", "models.server"
						, "-s", srcPath
					];
					if (project != null)
					{
						params.push("-p");
						params.push(project.projectFilePath);
					}
					Process.run("haxelib", params, true, log);
				}
				else
				{
					fail(
						  "databaseConnectionString not found.\n"
						+ "You may specify it in the 'config.xml' file:\n"
						+ "\t<config>\n"
						+ "\t\t<custom name=\"databaseConnectionString\" value=\"mysql://USER:PASSWORD@HOST/DATABASE\" />\n"
						+ "\t</config>\n"
						+ "or in the command line:\n"
						+ "\thaxelib run HaQuery orm mysql://USER:PASSWORD@HOST/DATABASE"
					);
				}
				
			};
			r.push( { name:name, description:description, options:options, run:run } );
		}
		
		return r;
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