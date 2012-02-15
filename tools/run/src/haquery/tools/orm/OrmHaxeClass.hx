package haquery.tools.orm;

import haquery.server.Lib;
import haquery.server.db.HaqDbDriver;

using haquery.StringTools;

typedef OrmHaxeVar = {>HaqDbTableFieldData,
	var haxeName : String;	
	var haxeType : String;
	var haxeDefVal : String;
}

class OrmHaxeClass
{
	var fullClassName : String;
	var baseFullClassName : String;
	
	var imports : Array<String>;
	var vars : Array<String>;
	var methods : Array<String>;
	
	public function new(fullClassName:String, baseFullClassName:String=null) : Void
	{
		this.fullClassName = fullClassName;
		this.baseFullClassName = baseFullClassName;
		this.imports = new Array<String>();
		this.vars = new Array<String>();
		this.methods = new Array<String>();
	}
	
	public function addImport(packageName:String) : Void
	{
		imports.push('import ' + packageName + ';');
	}
	
	public function addVar(v:OrmHaxeVar, isPrivate=false, isStatic=false) : Void
	{
		var s = (isPrivate ? '' : 'public ')
			  + (isStatic ? 'static ' : '')
			  + 'var ' + v.haxeName + ' : ' + v.haxeType
			  + (isStatic && v.haxeDefVal!=null ? ' = ' + v.haxeDefVal : '');
		vars.push(s);
 	}
	
	public function addMethod(name:String, vars:Iterable<OrmHaxeVar>, retType:String, body:String, isPrivate=false, isStatic=false) : Void
	{
		var header = 
				(isPrivate ? '' : 'public ')
			  + (isStatic ? 'static  ' : '')
			  + 'function ' + name + '('
			  + Lambda.map(vars, function(v:OrmHaxeVar) { return v.haxeName + ":" + v.haxeType + (v.haxeDefVal != null ? '=' + v.haxeDefVal : ''); } ).join(', ')
			  + ') : ' + retType;
		Lib.println("\t" + header);
		var s = header + '\n'
			  + '\t{\n'
			  + OrmTools.indent(body.trim(), '\t\t') + '\n'
			  + '\t}';
		methods.push(s);
 	}
	
	public function toString() : String
	{
		var clas = OrmTools.splitFullClassName(fullClassName);
		
		var s = 'package ' + clas.packageName + ';\n'
			  + '\n'
			  + imports.join('\n') + (imports.length > 0 ? '\n\n' : '')
			  + 'class ' + clas.className + (baseFullClassName != null ? ' extends ' + baseFullClassName : '') + '\n'
			  + '{\n'
			  + (vars.length > 0 ? '\t' + vars.join(';\n\t') + ';\n\n' : '')
			  + (methods.length > 0 ? '\t' + methods.join('\n\n\t') + '\n' : '')
			  + '}';
		return s;
	}
}