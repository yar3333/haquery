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
		new Build(exeDir).preBuild();
	}
	
	public function postBuild() : Bool
	{
		return new Build(exeDir).postBuild();
	}
	
	public function install()
	{
		new Setup(exeDir).install();
	}
	
	public function genOrm(databaseConnectionString:String, destBasePath:String)
    {
		var log = new Log(2);
        
		log.start("Generate object related mapping classes");
		
		OrmGenerator.run(new HaqDb(databaseConnectionString), log, destBasePath);
        
        log.finishOk();
    }
	
	public function genTrm()
	{
		new Build(exeDir).genTrm();
	}
}