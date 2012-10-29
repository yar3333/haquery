package haquery.tools;

import haquery.server.db.HaqDb;
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
    
	public function preBuild(noGenCode:Bool, isJsModern:Bool, isDeadCodeElimination:Bool)
	{
		return new Build(exeDir).preBuild(noGenCode, isJsModern, isDeadCodeElimination);
	}
	
	public function postBuild() : Bool
	{
		return new Build(exeDir).postBuild();
	}
	
	public function install()
	{
		new Setup(exeDir).install();
	}
	
	public function genOrm(databaseConnectionString:String, project:FlashDevelopProject)
    {
		var log = new Log(2);
        
		log.start("Generate object related mapping classes");
		
		OrmGenerator.run(new HaqDb(databaseConnectionString), log, project);
        
        log.finishOk();
    }
	
	public function genTrm()
	{
		new Build(exeDir).genTrm();
	}
	
	public function genCode()
	{
		return new Build(exeDir).genCode();
	}
}