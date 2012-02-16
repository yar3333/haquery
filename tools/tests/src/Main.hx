package ;

import Imports;

#if php

import php.Lib;
import tests.HaqTemplatesTest;
import tests.HaqXmlTest;
import tests.HaqQueryTest;
import haquery.server.HaqXml;
#end

class Main
{
    static function main()
	{
		#if php
			var r = new haxe.unit.TestRunner();
			
			r.add(new HaqXmlTest());
			r.add(new HaqQueryTest());
			r.add(new HaqTemplatesTest());
			
			Lib.println("<pre>");
			r.run();
			Lib.println("</pre>");
			
			
			/*Lib.println("<pre>");
			var nodes = HaqXmlParser.parse("<a>abc<div id=test>def</div></a>");
			Lib.println("</pre>");*/
		#end
	}
}
