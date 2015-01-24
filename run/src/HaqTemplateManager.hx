import hant.Log;
import hant.Path;
import haquery.common.HaqComponentTools;
import haquery.common.HaqDefines;
import haquery.common.HaqTemplateExceptions;
import stdlib.Exception;
import stdlib.FileSystem;
import htmlparser.HtmlNodeElement;
using stdlib.StringTools;
using Lambda;

class PathNotFoundException extends Exception {}

class HaqTemplateManager
{
	var classPaths : Array<String>;
	var basePage : String;
	var staticUrlPrefix : String;
	var substitutes : Array<{ from:EReg, to:String }>;
	var onlyPagesPackage : Array<String>;
	var ignorePages : Array<String>;
	
	var templates(default, null) : Map<String,HaqTemplate>;
	
	public var fullTags(default, null) : Array<String>;
	
	
	public function new(classPaths:Array<String>, basePage:String, staticUrlPrefix:String, substitutes:Array<{ from:EReg, to:String }>, onlyPagesPackage:Array<String>, ignorePages:Array<String>)
	{
		this.classPaths = classPaths;
		this.basePage = basePage;
		this.staticUrlPrefix = staticUrlPrefix;
		this.substitutes = substitutes;
		this.onlyPagesPackage = onlyPagesPackage;
		this.ignorePages = ignorePages;
		
		templates = new Map<String,HaqTemplate>();
		fillTemplates(HaqDefines.folders.pages, new Map<String, Int>());
		for (template in templates)
		{
			resolveComponentTags(template, template.doc);
		}
		
		fullTags = getUsedFullTags();
		for (fullTag in templates.keys())
		{
			if (!Lambda.has(fullTags, fullTag))
			{
				templates.remove(fullTag);
			}
		}
		fullTags.sort(function(a, b) return a<b ? -1 : (a>b?1:0));
	}
	
	function fillTemplates(pack:String, processedPacks:Map<String, Int>)
	{
		if (processedPacks.exists(pack)) return;
		
		var localPath = pack.replace(".", "/");
		
		var pathWasFound = false;
		
		var i = classPaths.length - 1;
		while (i >= 0)
		{
			var path = Path.join([ classPaths[i], localPath ]);
			if (!ignorePages.exists(function(s) return (path + "/").startsWith(s)))
			{
				if (FileSystem.exists(path) && FileSystem.isDirectory(path))
				{
					pathWasFound = true;
					
					var files : Array<String> = null; 
					try
					{
						files = FileSystem.readDirectory(path);
					}
					catch (e:Dynamic)
					{
						Log.echo("Can't read directory '" + path + "'.");
						Exception.rethrow(e);
					}
					
					for (file in files)
					{
						if (file != HaqDefines.folders.support && FileSystem.isDirectory(path + '/' + file))
						{
							addTemplate(pack + "." + file, processedPacks);
							if (processedPacks.exists(pack)) break;
						}
					}
				}
			}
			i--;
		}
		
		processedPacks.set(pack, 1);
		
		if (!pathWasFound)
		{
			throw new PathNotFoundException("Components path '" + localPath + "' not found.");
		}
	}
	
	function addTemplate(fullTag:String, processedPacks:Map<String, Int>)
	{
		if (fullTag != null && fullTag != "" && !templates.exists(fullTag))
		{
			try
			{
				var template = new HaqTemplate(classPaths, fullTag, basePage, staticUrlPrefix, substitutes);
				templates.set(fullTag, template);
				
				addTemplate(template.extend, processedPacks);
				
				for (imp in template.imports)
				{
					if (imp.asTag == null)
					{
						fillTemplates(imp.component, processedPacks);
					}
					else
					{
						addTemplate(imp.component, processedPacks);
					}
				}
			}
			catch (e:HaqTemplateNotFoundException)
			{
				fillTemplates(fullTag, processedPacks);
			}
		}
	}
	
	function getUsedFullTags() : Array<String>
	{
		var usedFullTags = new Array<String>();
		for (fullTag in templates.keys())
		{
			if (
				fullTag.startsWith(HaqDefines.folders.pages + ".")
			 && (onlyPagesPackage.length == 0 || onlyPagesPackage.exists(function(s) return (fullTag + ".").startsWith(s)))
			) {
				getUsedFullTags_addToUsed(get(fullTag), usedFullTags);
			}
		}
		return usedFullTags;
	}
	
	function getUsedFullTags_addToUsed(template:HaqTemplate, usedFullTags:Array<String>)
	{
		if (template != null && !Lambda.has(usedFullTags, template.fullTag))
		{
			usedFullTags.push(template.fullTag);
			
			if (template.extend != "")
			{
				getUsedFullTags_addToUsed(get(template.extend), usedFullTags);
			}
			
			for (require in template.requires)
			{
				getUsedFullTags_addToUsed(get(require), usedFullTags);
			}
			
			for (tag in getUsedFullTags_getDocTags(template.doc))
			{
				getUsedFullTags_addToUsed(get(tag), usedFullTags);
			}
		}
	}
	
	function getUsedFullTags_getDocTags(doc:HtmlNodeElement) : Array<String>
	{
		var r = [];
		for (node in doc.children)
		{
			if (node.name.startsWith("haq:"))
			{
				r.push(HaqComponentTools.htmlTagToFullTag(node.name.substr("haq:".length)));
			}
			r = r.concat(getUsedFullTags_getDocTags(node));
		}
		return r;
	}
	
	function getFullPath(path:String)
	{
		var i = classPaths.length - 1;
		while (i >= 0)
		{
			var fullPath = Path.join([ classPaths[i], path ]);
			if (FileSystem.exists(fullPath))
			{
				return fullPath;
			}
			i--;
		}
		return null;
	}
	
	function resolveComponentTags(parent:HaqTemplate, doc:HtmlNodeElement)
	{
		for (node in doc.children)
		{
			if (node.name.startsWith("haq:"))
			{
				var tag = node.name.substr("haq:".length).replace("-", ".");
				
				if (node.getAttribute("__parent") == null)
				{
					throw new HaqTemplateNotFoundCriticalException("__parent not defined for tag 'haq:" + tag + "' in '" + parent.fullTag + "'.");
				}
				
				var baseTemplate = resolveComponentTag(get(node.getAttribute("__parent")), tag);
				if (baseTemplate == null)
				{
					throw new HaqTemplateNotFoundCriticalException("Component '" + tag + "' used in '" + node.getAttribute("__parent") + "' can not be resolved.");
				}
				
				var realTemplate = resolveComponentTag(parent, tag);
				if (realTemplate == null)
				{
					throw new HaqTemplateNotFoundCriticalException("Component '" + tag + "' used in '" + parent.fullTag + "' can not be resolved.");
				}
				
				if (!isTemplateExtends(realTemplate, baseTemplate))
				{
					throw new HaqTemplateNotFoundCriticalException("Component '" + tag + "' (resolved as '" + realTemplate.fullTag + "') used in '" + parent.fullTag + "' must be extended from '" + baseTemplate.fullTag + "'.");
				}
				
				node.removeAttribute("__parent");
				node.name = "haq:" + HaqComponentTools.fullTagToHtmlTag(realTemplate.fullTag);
			}
			
			resolveComponentTags(parent, node);
		}
	}
	
	public function resolveComponentTag(parent:HaqTemplate, tag:String) : HaqTemplate
	{
		if (tag.indexOf(".") >= 0)
		{
			return get(HaqDefines.folders.components + "." + tag);
		}
	
		for (imp in get(parent.fullTag).imports)
		{
			if (imp.asTag != null)
			{
				if (imp.asTag == tag)
				{
					return get(imp.component);
				}
			}
			else 
			{
				var template = get(imp.component + "." + tag);
				if (template != null)
				{
					return template;
				}
			}
		}
		
		return null;
	}
	
	function isTemplateExtends(realTemplate:HaqTemplate, baseTemplate:HaqTemplate)
	{
		if (realTemplate == null || baseTemplate == null) return false;
		if (realTemplate.fullTag == baseTemplate.fullTag) return true;
		if (realTemplate.extend == "") return false;
		return isTemplateExtends(get(realTemplate.extend), baseTemplate);
	}
	
	public function get(fullTag:String) : HaqTemplate
	{
		if (templates.exists(fullTag))
		{
			var r = templates.get(fullTag);
			if (r == null)
			{
				r = new HaqTemplate(classPaths, fullTag, basePage, staticUrlPrefix, substitutes);
				templates.set(fullTag, r);
			}
			return r;
		}
		return null;
	}
}
