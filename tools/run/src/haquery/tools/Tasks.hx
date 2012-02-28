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
		new Build(exeDir, getHaxePath()).preBuild();
	}
	
	public function postBuild(skipJS:Bool, skipComponents:Bool) : Bool
	{
		return new Build(exeDir, getHaxePath()).postBuild(skipJS, skipComponents);
	}
	
	public function install()
	{
		new Setup(exeDir, getHaxePath()).install();
	}
	
	public function uninstall()
	{
		new Setup(exeDir, getHaxePath()).uninstall();
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
		new Build(exeDir, getHaxePath()).genTrm();
	}
	
	function getHaxePath()
    {
        var r = Sys.getEnv('HAXEPATH');
        
        if (r == null)
        {
            throw "HaXe not found (HAXEPATH environment variable not set).";
        }
		
		r = r.replace("\\", "/");
        while (r.endsWith('/'))
        {
            r = r.substr(0, r.length - 1);
        }
        r += '/';
        
        if (!FileSystem.exists(r + 'haxe.exe'))
        {
            throw "HaXe not found (file '" + r + "haxe.exe' does not exist).";
        }
        
        return r;
    }
}