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
	var serverClass : Class<HaqComponent>;
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
		this.componentsFolders = [];
		for (folder in componentsFolders)
		{
			this.componentsFolders.push(path2relative(folder));
		}
		
		templates = new Hash<Hash<HaqCachedTemplate>>();
		for (folder in this.componentsFolders)
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
		var r : HaqTemplate = { doc : null, serverHandlers : null, serverClass : null };

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
			
			if (r.serverClass == null)
			{
				var className = componentsFolder.replace('/', '.') + tag + '.Server';
				r.serverClass = untyped Type.resolveClass(className);
			}
			
			i--;
		}
		
		if (r.doc == null && r.serverHandlers == null && r.serverClass == null)
		{
			throw 'Component "' + tag + '" not found.';
		}
		
		if (r.serverClass == null) r.serverClass = haquery.server.HaqComponent;
		
		return r;
	}
	
	private function build(componentsFolder : String) : Hash<HaqCachedTemplate>
	{
		var dataFilePath = HaQuery.folders.temp + componentsFolder + 'components.data';
		var stylesFilePath = HaQuery.folders.temp + componentsFolder + 'styles.css';
		
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
	
	static public function parsePage(pageFolder:String) : { doc:HaqXml, serverHandlers : Hash<Array<String>> }
	{
		pageFolder = path2relative(pageFolder);
		
		var templatePath = pageFolder + 'template.phtml';
		var text = FileSystem.exists(templatePath) ? getTemplateText(templatePath) : '';
		
        var doc = new HaqXml(text);
		var serverHandlers = parseComponentServerHandlers(pageFolder);
		
		return { doc:doc, serverHandlers:serverHandlers };
	}
	
	function parseComponent(componentFolder:String) : { css:String, doc:HaqXml, serverHandlers : Hash<Array<String>> }
	{
		var tag = Path.withoutDirectory(componentFolder);
		
		var templatePath = getFileUrl(tag, 'template.phtml');
		var text = '';
		if (templatePath != null)
		{
			text = getTemplateText(templatePath);
			var supportUrl = getFileUrl(tag, 'support');
			if (supportUrl != null)
			{
				text = text.replace('~/', supportUrl + '/');
			}
		}
		
        var cssAndDoc = parseComponentTemplate(text);
		var serverHandlers = parseComponentServerHandlers(componentFolder);
		
		return { css:cssAndDoc.css, doc:cssAndDoc.doc, serverHandlers:serverHandlers };
	}
	
	static function parseComponentTemplate(text:String) : { css:String, doc:HaqXml }
	{
        HaqProfiler.begin('HaqTemplate::parseComponent(): template file -> doc and css');
			var css = '';
			var doc = new HaqXml(text);
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
		
		return { css:css, doc:doc };
	}
	
	static function parseComponentServerHandlers(componentFolder:String) : Hash<Array<String>>
	{
		HaqProfiler.begin('HaqTemplate::parseComponent(): component server class -> handlers');
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
		
		return serverHandlers;
	}
	
	public function getStyleFilePaths() : Array<String>
	{
		var r = new Array<String>();
		for (folder in componentsFolders)
		{
			var path = HaQuery.folders.temp + folder + 'styles.css';
			if (FileSystem.exists(path))
			{
				r.push(path);
			}
		}
		return r;
	}
	
	public function getFileUrl(tag:String, filePathRelativeToComponentFolder:String) : String
	{
		filePathRelativeToComponentFolder = filePathRelativeToComponentFolder.trim('/');
		var i = componentsFolders.length - 1;
		while (i >= 0)
		{
			var path = componentsFolders[i] + tag + '/' + filePathRelativeToComponentFolder;
			if (FileSystem.exists(path))
			{
				return '/' + path;
			}
			i--;
		}
		return null;
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
	
	static function getTemplateText(templatePath:String) : String
	{
		untyped __call__('ob_start');
		untyped __call__('include', templatePath);
		var text : String = untyped __call__('ob_get_clean');
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