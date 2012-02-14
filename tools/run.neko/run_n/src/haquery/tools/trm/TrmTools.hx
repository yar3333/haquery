package haquery.tools.trm;

import haquery.server.FileSystem;
import haquery.server.io.File;
import haquery.tools.trm.TrmHaxeClass;

using haquery.StringTools;

class TrmTools 
{
	public static function capitalize(s:String) : String
	{
		return s.length == 0 ? s : s.substr(0, 1).toUpperCase() + s.substr(1);
	}
	
	public static function indent(text:String, ind = "\t") : String
    {
        if (text == '') return '';
		return ind + text.replace("\n", "\n" + ind);
    }
	
	public static function splitFullClassName(fullClassName:String) : { packageName:String, className:String }
	{
		var packageName = '';
		var className = fullClassName;
		
		if (fullClassName.lastIndexOf('.') != -1)
		{
			packageName = fullClassName.substr(0, fullClassName.lastIndexOf('.'));
			className = fullClassName.substr(fullClassName.lastIndexOf('.') + 1);
		}
		
		return { packageName:packageName, className:className };
	}
	
	public static function createVar(name:String, type:String,defVal:String = null) : TrmHaxeVar
	{
		return {
			 name : name
			,type : type
			,defVal : defVal
		};
	}
	
	static var classPaths : Array<String>;
	public static function getClassPaths() : Array<String>
	{
		if (classPaths == null)
		{
			var haqueryPath = untyped __php__("dirname(__FILE__)");
			haqueryPath += "/../../..";
			haqueryPath = FileSystem.fullPath(haqueryPath);
			haqueryPath = haqueryPath.replace("\\", "/") + "/";
			
			classPaths = [ haqueryPath ];
			
			var files = FileSystem.readDirectory('.');
			for (file in files)
			{
				if (file.endsWith('.hxproj'))
				{
					var text = File.getContent(file);
					text = text.replace('<?xml version="1.0" encoding="utf-8"?>', '');
					var xml = Xml.parse(text);
					var fast = new haxe.xml.Fast(xml.firstElement());
					if (fast.hasNode.classpaths)
					{
						var cp = fast.node.classpaths;
						for (elem in cp.elements)
						{
							if (elem.name == 'class' && elem.has.path)
							{
								classPaths.push(elem.att.path.replace('\\', '/').rtrim("/") + "/");
							}
						}
					}
				}
			}
		}
		return classPaths;
	}
}