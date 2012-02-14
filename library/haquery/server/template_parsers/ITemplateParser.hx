package haquery.server.template_parsers;

import haquery.server.HaqXml;
import haquery.server.HaqComponent;

interface ITemplateParser
{
	function getDocAndCss() : { css:String, doc:HaqXml };
	function getServerClass() : Class<HaqComponent>;
	function getServerHandlers() : Hash<Array<String>>;
	function getSupportFilePath(fileName:String) : String;
	function getCollectionName() : String;
	function getExtendsCollectionName() : String;
}
