package haquery.server.template_parsers;

import haquery.server.HaqDefines;
import haquery.server.HaqXml;

class PageTemplateParser implements ITemplateParser
{
	var pagePackage : String;
	
	public function new(pagePackage:String)
	{
		this.pagePackage = pagePackage;
	}
	
	public function getServerClass() : Class<HaqComponent>
	{
		var clas = Type.resolveClass(pagePackage + ".Server");
		return clas != null ? clas : HaqPage;
	}
	
	public function getRawTemplateHtml() : String
	{
		var templatePath = pagePackage.replace('.', '/') + '/template.html';
		return FileSystem.exists(templatePath) ? File.getContent(templatePath) : '';
	}
	
	public function findSupportFile(fileName:String) : String
	{
		var path = pagePackage.replace('.', '/') + '/' + HaqDefines.folders.support + '/' + fileName;
		return FileSystem.exists(path) ? path : null;
	}
	
	public function getDoc() : { css:String, doc:HaqXml }
	{
		var pageText = getRawTemplateHtml();
        
        var pageDoc = new HaqXml(pageText);
        
        if (Lib.config.layout == null || Lib.config.layout == "") return pageDoc;
        
        if (!FileSystem.exists(Lib.config.layout))
        {
            throw "Layout file '" + Lib.config.layout + "' not found.";
        }
        
        var layoutDoc = new HaqXml(File.getContent(Lib.config.layout));
        
        var placeholders : Array<HaqXmlNodeElement> = untyped Lib.toHaxeArray(layoutDoc.find('haq:placeholder'));
        var contents : Array<HaqXmlNodeElement> = untyped Lib.toHaxeArray(pageDoc.find('>haq:content'));
        for (ph in placeholders)
        {
            var content : HaqXmlNodeElement = null;
            for (c in contents) 
            {
                if (c.getAttribute('id')==ph.getAttribute('id'))
                {
                    content = c;
                    break;
                }
            }
            if (content!=null) ph.parent.replaceChildWithInner(ph, content);
            else               ph.parent.replaceChildWithInner(ph, ph);
        }
        
		return { css:"", doc:layoutDoc };
	}
}