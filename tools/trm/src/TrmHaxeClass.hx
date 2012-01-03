package ;

import php.Lib;

using haquery.StringTools;

typedef TrmHaxeVar = {
	var name : String;
	var type : String;
	var defVal : String;
}

class TrmHaxeClass
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
	
	public function addVar(v:TrmHaxeVar, isPrivate=false, isStatic=false) : Void
	{
		var s = (isPrivate ? '' : 'public ')
			  + (isStatic ? 'static ' : '')
			  + 'var ' + v.name + ' : ' + v.type
			  + (isStatic && v.defVal!=null ? ' = ' + v.defVal : '');
		vars.push(s);
 	}
	
	public function addMethod(name:String, vars:Iterable<TrmHaxeVar>, retType:String, body:String, isPrivate=false, isStatic=false) : Void
	{
		var header = 
				(isPrivate ? '' : 'public ')
			  + (isStatic ? 'static  ' : '')
			  + 'function ' + name + '('
			  + Lambda.map(vars, function(v:TrmHaxeVar) { return v.name + ":" + v.type + (v.defVal != null ? '=' + v.defVal : ''); } ).join(', ')
			  + ') : ' + retType;
		Lib.println("\t" + header);
		var s = header + '\n'
			  + '\t{\n'
			  + TrmTools.indent(body.trim(), '\t\t') + '\n'
			  + '\t}';
		methods.push(s);
 	}
	
	public function toString() : String
	{
		var clas = TrmTools.splitFullClassName(fullClassName);
		
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