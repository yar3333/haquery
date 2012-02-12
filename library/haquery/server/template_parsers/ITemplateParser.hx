package haquery.server.template_parsers;

import haquery.server.HaqXml;
import haquery.server.HaqComponent;

interface ITemplateParser
{
	function getDoc() : { css:String, doc:HaqXml };
	function getServerClassName() : String;
	function getConfig() : ComponentConfig;
}