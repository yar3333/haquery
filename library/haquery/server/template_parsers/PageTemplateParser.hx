package haquery.server.template_parsers;

import haquery.server.HaqDefines;
import haquery.server.HaqComponent;
import haquery.server.HaqXml;
import haquery.server.HaqPage;
import haquery.server.FileSystem;
import haquery.server.io.File;

using haquery.StringTools;

class PageTemplateParser extends BaseTemplateParser
{
	var pagePackage : String;
	
	public function new(pagePackage:String)
	{
		this.pagePackage = pagePackage;
	}
	
	override public function getServerClass() : Class<HaqComponent>
	{
		var clas = Type.resolveClass(pagePackage + ".Server");
		return cast (clas != null ? clas : HaqPage);
	}
	
	override public function getServerHandlers() : Hash<Array<String>>
	{
        Lib.profiler.begin('parseServerHandlers');
            var serverMethods = [ 'click','change' ];   // server events
            var serverHandlers : Hash<Array<String>> = new Hash<Array<String>>();
            var tempObj = Type.createEmptyInstance(getServerClass());
            for (field in Reflect.fields(tempObj))
            {
                if (Reflect.isFunction(Reflect.field(tempObj, field)))
                {
                    var parts = field.split('_');
                    if (parts.length == 2 && Lambda.has(serverMethods, parts[1]))
                    {
                        var nodeID = parts[0];
                        var method = parts[1];
                        if (!serverHandlers.exists(nodeID))
						{
							serverHandlers.set(nodeID, new Array<String>());
						}
                        serverHandlers.get(nodeID).push(method);
                    }
                }
            }
        Lib.profiler.end();
		
		return serverHandlers;
	}
	
	public function getRawTemplateHtml() : String
	{
		var templatePath = pagePackage.replace('.', '/') + '/template.html';
		return FileSystem.exists(templatePath) ? File.getContent(templatePath) : '';
	}
	
	override public function getSupportFilePath(fileName:String) : String
	{
		var path = pagePackage.replace('.', '/') + '/' + HaqDefines.folders.support + '/' + fileName;
		return FileSystem.exists(path) ? path : null;
	}
	
	override public function getDocAndCss() : { doc:HaqXml, css:String }
	{
		var pageText = getRawTemplateHtml();
        
        var pageDoc = new HaqXml(pageText);
        
        if (Lib.config.layout == null || Lib.config.layout == "") return { doc:pageDoc, css:"" };
        
        if (!FileSystem.exists(Lib.config.layout))
        {
            throw "Layout file '" + Lib.config.layout + "' not found.";
        }
        
        var layoutDoc = new HaqXml(File.getContent(Lib.config.layout));
        
        var placeholders = layoutDoc.find('haq:placeholder');
        var contents = pageDoc.find('>haq:content');
        for (ph in placeholders)
        {
            var content : HaqXmlNodeElement = null;
            for (c in contents) 
            {
                if (c.getAttribute('id') == ph.getAttribute('id'))
                {
                    content = c;
                    break;
                }
            }
            if (content != null) ph.parent.replaceChildWithInner(ph, content);
            else                 ph.parent.replaceChildWithInner(ph, ph);
        }
        
		return { doc:layoutDoc, css:"" };
	}
	
	override public function getCollectionName() : String
	{
		return "";
	}

	override public function getExtendsCollectionName() : String
	{
		return "";
	}
}