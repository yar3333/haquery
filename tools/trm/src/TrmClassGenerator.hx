package ;

import php.FileSystem;
import php.io.File;
import php.io.FileOutput;
import php.Lib;
import TrmHaxeClass;

using haquery.StringTools;

class TrmClassGenerator 
{
	static public function make(basePath:String, componentPackage:String)
	{
		trace("TrmClassGenerator basePath = " + basePath + "; componentPackage = " + componentPackage);
		
		/*var code : OrmHaxeClass = new OrmHaxeClass(componentPackage + ".Template", null);
		
		//code.addImport('haquery.server.db.HaqDb');
		
		code.addMethod('set', settedVars, 'Void',
			Lambda.map(settedVars, function(v:OrmHaxeVar) { return 'this.' + v.haxeName + " = " + v.haxeName + ";"; }).join('\n')
		);
		
		File.putContent(basePath + componentPackage.replace('.', '/') + '/Template.hx', code.toString());*/
	}
}