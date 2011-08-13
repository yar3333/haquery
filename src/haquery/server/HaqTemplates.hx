package haquery.server;

import php.FileSystem;
import php.io.File;
import php.io.Path;
import php.Lib;
import haquery.server.HaqXml;
import haquery.server.HaQuery;

typedef HaqTemplate =
{ 
	var doc : HaqXml;
	var serverHandlers: Hash<Array<String>>;
	var cssClass : Class<HaqComponent>;
}

private typedef HaqCachedTemplate = {
    var serializedDoc : String;
    var serverHandlers : Hash<Array<String>>;
}

class HaqTemplates
{
	var componentsFolders : Array<String>;
	var templates : Hash<Hash<HaqCachedTemplate>>; // templates.get(relativePathToComponentsFolder).get(tag)
	
	public function new(componentsFolders : Array<String>) : Void
	{
		//trace('new componentsFolders.length = ' + componentsFolders.length);
		
		this.componentsFolders = componentsFolders;
		templates = new Hash<Hash<HaqCachedTemplate>>();
		
		for (folder in componentsFolders)
		{
			templates.set(folder, build(folder));
		}
	}
	
	public function getTags() : Array<String>
	{
        var tags : Array<String> = new Array<String>();
		for (componentsFolder in componentsFolders)
		{
			for (tag in FileSystem.readDirectory(componentsFolder))
			{
				if (tags.indexOf(tag) == -1) tags.push(tag);
			}
		}
		return tags;
	}
	
	public function get(tag:String) : HaqTemplate
	{
		var r : HaqTemplate = { doc : null, serverHandlers : null, cssClass : null };

		var i = componentsFolders.length - 1;
		while (i >= 0)
		{
			var componentsFolder = componentsFolders[i];
			if (templates.exists(componentsFolder) && templates.get(componentsFolder).exists(tag))
			{
				var t = templates.get(componentsFolder).get(tag);
				if (r.doc == null && t.serializedDoc != null) r.doc = Lib.unserialize(t.serializedDoc);
				if (r.serverHandlers == null && t.serverHandlers != null) r.serverHandlers = t.serverHandlers;
			}
			
			if (r.cssClass == null)
			{
				var className = path2relative(componentsFolder).replace('/', '.') + tag + '.Server';
				//trace('Test class for existance: ' + className);
				r.cssClass = untyped Type.resolveClass(className);
			}
			
			i--;
		}
		
		if (r.doc == null && r.serverHandlers == null && r.cssClass == null)
		{
			throw 'Component "'+tag+'" not found.';
		}
		
		if (r.cssClass == null) r.cssClass = haquery.server.HaqComponent;
		
		return r;
	}
	
	private function build(componentsFolder : String) : Hash<HaqCachedTemplate>
	{
		componentsFolder = path2relative(componentsFolder);
		//trace('componentsFolder = ' + componentsFolder);
		
		var dataFilePath = HaQuery.folders.temp + componentsFolder + 'components.data';
		var stylesFilePath = HaQuery.folders.temp + componentsFolder + 'styles.css';
		
		//trace('dataFilePath = ' + dataFilePath);
		var templatePaths : Array<String> = getComponentTemplatePaths(componentsFolder);
		var cacheFileTime = FileSystem.exists(dataFilePath)  ? FileSystem.stat(dataFilePath).mtime.getTime() : 0.0;
		if (!FileSystem.exists(dataFilePath) 
		  || Lambda.exists(templatePaths, function(path):Bool { return FileSystem.stat(path).mtime.getTime() >  cacheFileTime; } )
		) {
			var css = '';
			var data : Hash<HaqCachedTemplate> = new Hash<HaqCachedTemplate>();
			
			// TODO: папка в public может и отсутствовать
			for (folder in FileSystem.readDirectory(componentsFolder))
			{
				var parts : { css:String, doc:HaqXml, serverHandlers : Hash<Array<String>> } = parseComponent(componentsFolder+folder);
				css += parts.css;
				data.set(folder, { serializedDoc: Lib.serialize(parts.doc), serverHandlers: parts.serverHandlers });
			}
			if (!FileSystem.exists(Path.directory(stylesFilePath)))
			{
				createDirectory(Path.directory(stylesFilePath));
			}
			File.putContent(stylesFilePath, css);
			File.putContent(dataFilePath, Lib.serialize(data));
			
			return data;
		}
		else
		{
			var data : Hash<HaqCachedTemplate> = Lib.unserialize(File.getContent(dataFilePath));
			return data;
		}
	}
	
	static public function parseComponent(componentFolder:String) : { css:String, doc:HaqXml, serverHandlers : Hash<Array<String>> }
	{
		componentFolder = path2relative(componentFolder);
		//trace('componentFolder = ' + componentFolder);
		
		var templatePath = componentFolder + 'template.phtml';
		
        HaqProfiler.begin('HaqCache::parseComponent(): template file -> doc and css');
			var css = '';
			var doc = new HaqXml(FileSystem.exists(templatePath) ? getTemplateText(templatePath) : '');
			var i = 0; 
			var children : Array<HaqXmlNodeElement> = untyped Lib.toHaxeArray(doc.children);
			while (i < children.length)
			{
				var node : HaqXmlNodeElement = children[i];
				if (node.name=='style' && !node.hasAttribute('id'))
				{
					css += node.innerHTML;
					node.remove();
					children.splice(i, 1);
					i--;
				}
				i++;
			}
        HaqProfiler.end();
        
		HaqProfiler.begin('HaqCache::parseComponent(): component server class -> handlers');
            var serverMethods = [ 'click','change' ];   // какие серверные обработчики бывают
            var serverHandlers : Hash<Array<String>> = new Hash<Array<String>>();
			var className = componentFolder.replace('/', '.') + 'Server';
			//trace('test class name = '+className);
			var clas = Type.resolveClass(className); 
			if (clas != null) 
			{
				var tempObj = Type.createEmptyInstance(clas);
				//trace(className + ' => ' + Type.getInstanceFields(clas).length);
				for (field in Type.getInstanceFields(clas))
				{
					//trace('Test ' + field);
					if (Reflect.isFunction(Reflect.field(tempObj, field)))
					{
						//trace('======>OK');
						var parts = field.split('_');
						if (parts.length == 2 && serverMethods.indexOf(parts[1]) >= 0)
						{
							var nodeID = parts[0];
							var method = parts[1];
							if (!serverHandlers.exists(nodeID)) serverHandlers.set(nodeID, new Array<String>());
							//trace('finded method = ' + method);
							serverHandlers.get(nodeID).push(method);
						}
					}
				}
			}
        HaqProfiler.end();
		
		return { css:css, doc:doc, serverHandlers:serverHandlers };
	}
	
	public function getStyleFilePaths() : Array<String>
	{
		var r = new Array<String>();
		for (folder in componentsFolders)
		{
			var path = HaQuery.folders.temp + path2relative(folder) + 'styles.css';
			if (FileSystem.exists(path))
			{
				r.push(path);
			}
		}
		return r;
	}
	
	static function getComponentTemplatePaths(componentsFolder:String) : Array<String>
	{
		componentsFolder = componentsFolder.rtrim('/') + '/';
		
		var r = new Array<String>();
		var folders = FileSystem.readDirectory(componentsFolder);
		for (folder in folders)
		{
			var templatePath = componentsFolder + folder + '/template.phtml';
			if (FileSystem.exists(templatePath))
			{
				r.push(templatePath);
			}
			
		}
		return r;
	}
	
	static private function path2relative(path:String) : String
	{
		path = FileSystem.fullPath(path).replace('\\', '/').rtrim('/');
		var basePath = FileSystem.fullPath('').replace('\\', '/').rtrim('/');
		if (!path.startsWith(basePath)) throw 'path2relative with path = ' + path;
		path = path.substr(basePath.length + 1);
		return path.length > 0 ? path + '/' : '';
	}
	
	static function getTemplateText(path:String) : String
	{
		untyped __call__('ob_start');
		untyped __call__('include', path);
		var text : String = untyped __call__('ob_get_clean');
		var supportUrl = '/' + path2relative(Path.directory(path)) + 'support/';
		text = text.replace('~/', supportUrl);
		return text;
	}
	
	public function getInternalDataForPageHtml() : String
	{
        var s = "haquery.client.HaqInternals.componentsFolders = [\n";
        for (folder in componentsFolders)
        {
                s += "    '" + path2relative(folder) + "',\n";
        }
        s = s.rtrim("\n,") + "\n];";
		return s;
	}
	
	static function createDirectory(path:String)
	{
		var parentPath = Path.directory(path);
		if (parentPath != null && parentPath != '' && !FileSystem.exists(parentPath)) createDirectory(parentPath);
		FileSystem.createDirectory(path);
	}
}