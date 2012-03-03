package haquery.tools;

import neko.Sys;

import haquery.server.db.HaqDb;
import haquery.server.FileSystem;
import haquery.server.Lib;
import haquery.tools.orm.OrmGenerator;
import haquery.tools.tasks.Build;
import haquery.tools.tasks.Setup;

using haquery.StringTools;

class Tasks 
{
	var exeDir : String;
    
    public function new(exeDir:String)
    {
		this.exeDir = exeDir.replace('\\', '/');
    }
    
	public function preBuild()
	{
		new Build(exeDir).preBuild();
	}
	
	public function postBuild(skipJS:Bool, skipComponents:Bool) : Bool
	{
		return new Build(exeDir).postBuild(skipJS, skipComponents);
	}
	
	public function install()
	{
		new Setup(exeDir).install();
	}
	
	public function uninstall()
	{
		new Setup(exeDir).uninstall();
	}
    
	public function genOrm(databaseConnectionString:String, destBasePath:String)
    {
		var log = new Log(2);
        
		log.start("Generate object related mapping classes");
		
		HaqDb.connect(databaseConnectionString);
		
		OrmGenerator.run(log, destBasePath);
        
        log.finishOk();
    }
	
	public function genTrm()
	{
		new Build(exeDir).genTrm();
	}
}