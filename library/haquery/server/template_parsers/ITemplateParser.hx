package haquery.server.template_parsers;

import haquery.server.HaqXml;
import haquery.server.HaqComponent;

interface ITemplateParser
{
	function getFullTag() : String;
	function getDocAndCss() : { css:String, doc:HaqXml };
	function getClass() : Class<HaqComponent>;
	function getServerHandlers() : Hash<Array<String>>;
	function getSupportFilePath(fileName:String) : String;
	function getImports() : Array<String>;
}
