package haquery.tools;

import neko.Sys;

import haquery.server.db.HaqDb;
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
	
	public function postBuild(skipJS:Bool, skipComponents:Bool)
	{
		new Build(exeDir).postBuild(skipJS, skipComponents);
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
        
		var re = new EReg('^([a-z]+)\\://([_a-zA-Z0-9]+)\\:(.+?)@([_a-zA-Z0-9]+)/([_a-zA-Z0-9]+)$', '');
		if (!re.match(databaseConnectionString))
		{
			Lib.println("Connection string example: 'mysql://root:123456@localhost/mydb'.");
			Sys.exit(1);
		}
		
		HaqDb.connect({
			 type : re.matched(1)
			,user : re.matched(2)
			,pass : re.matched(3)
			,host : re.matched(4)
			,database : re.matched(5)
		});
		
		OrmGenerator.run(destBasePath);
        
        log.finishOk();
    }
	
	public function genTrm()
	{
		new Build(exeDir).genTrm();
	}
}