package haquery.server;

import haxe.Unserializer;
import htmlparser.HtmlDocument;
import haquery.common.HaqDefines;
import stdlib.FileSystem;
using stdlib.StringTools;

class HaqTemplate extends haquery.base.HaqTemplate
{
	public var extend(default, null) : String;
	public var serverClassName(default, null) : String;
	public var serializedDoc(default, null) : String;
	
	public var doc(get, null) : HtmlDocument;
	function get_doc() return Lib.cache.get(Type.getClassName(Type.getClass(this)) + ":" + fullTag, null, serializedDoc.length, function() return getDocCopy());
	
	public function new(fullTag:String) 
	{
		super(fullTag);
		
		var config = new HaqTemplateConfig(fullTag);
		
		extend = config.extend;
		serverClassName = config.serverClassName;
		serializedDoc = config.serializedDoc;
	}
	
	public function getSupportFilePath(fileName:String) : String
	{
		var path = fullTag.replace(".", "/") + "/" + HaqDefines.folders.support + "/" + fileName;
		if (FileSystem.exists(path.rtrim("/")))
		{
			return path;
		}
		return extend != "" 
			? new HaqTemplate(extend).getSupportFilePath(fileName)
			: null;
	}
	
	public function getDocCopy() : HtmlDocument
	{
		return Unserializer.run(serializedDoc);
	}
}
