package ;

import hant.Log;
import haquery.common.HaqComponentTools;
import haquery.common.HaqDefines;
import haquery.common.HaqTemplateExceptions;
import haquery.Exception;
import haquery.server.FileSystem;
import haxe.htmlparser.HtmlNodeElement;
using haquery.StringTools;

class PathNotFoundException extends Exception {}

class HaqTemplateManager
{
	var log : Log;
	var classPaths : Array<String>;
	var templates(default, null) : Hash<HaqTemplate>;
	
	public var fullTags(default, null) : Array<String>;
	
	public function new(log:Log, classPaths:Array<String>)
	{
		this.log = log;
		
		this.classPaths = classPaths;
		
		this.templates = new Hash<HaqTemplate>();
		fillTemplates(HaqDefines.folders.pages);
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
	
	function fillTemplates(pack:String)
	{
		var localPath = pack.replace(".", "/");
		
		var pathWasFound = false;
		
		var i = classPaths.length - 1;
		while (i >= 0)
		{
			var path = classPaths[i] + localPath;
			if (FileSystem.exists(path) && FileSystem.isDirectory(path))
			{
				pathWasFound = true;
				for (file in FileSystem.readDirectory(path))
				{
					if (file != HaqDefines.folders.support && FileSystem.isDirectory(path + '/' + file))
					{
						addTemplate(pack + "." + file);
					}
				}
			}
			i--;
		}
		
		if (!pathWasFound)
		{
			throw new PathNotFoundException("Components path '" + localPath + "' not found.");
		}
	}
	
	function addTemplate(fullTag:String)
	{
		if (fullTag != null && fullTag != "" && !templates.exists(fullTag))
		{
			try
			{
				var template = new HaqTemplate(log, classPaths, fullTag);
				templates.set(fullTag, template);
				
				addTemplate(template.extend);
				
				for (imp in template.imports)
				{
					if (imp.asTag == null)
					{
						fillTemplates(imp.component);
					}
					else
					{
						addTemplate(imp.component);
					}
				}
			}
			catch (e:HaqTemplateNotFoundException)
			{
				fillTemplates(fullTag);
			}
		}
	}
	
	function getUsedFullTags() : Array<String>
	{
		var usedFullTags = new Array<String>();
		for (fullTag in templates.keys())
		{
			if (fullTag.startsWith(HaqDefines.folders.pages + "."))
			{
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
			var fullPath = classPaths[i] + path;
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
	
	function resolveComponentTag(parent:HaqTemplate, tag:String) : HaqTemplate
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
				r = new HaqTemplate(log, classPaths, fullTag);
				templates.set(fullTag, r);
			}
			return r;
		}
		return null;
	}
}
