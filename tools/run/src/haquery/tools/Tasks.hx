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
    
	public function preBuild()
	{
		return new Build(exeDir).preBuild();
	}
	
	public function postBuild(isJsModern:Bool, isDeadCodeElimination:Bool) : Bool
	{
		return new Build(exeDir).postBuild(isJsModern, isDeadCodeElimination);
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
}