package haquery.server.template_parsers;

import haquery.server.HaqDefines;
import haquery.server.HaqComponent;
import haquery.server.HaqXml;
import haquery.server.HaqPage;
import haquery.server.FileSystem;
import haquery.server.io.File;

using haquery.StringTools;

class PageTemplateParser extends ComponentTemplateParser
{
	public function new(fullTag:String)
	{
		super(fullTag);
	}
	
	override function getBaseClass() : Class<HaqComponent>
	{
		return HaqPage;
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
}