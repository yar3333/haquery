package haquery.server;

import php.Lib;
import haquery.server.HaqComponent;

/**
 * Базовый класс для страниц.
 */
class HaqPage extends HaqComponent
{
	public var contentType : String;
	
	public function new() : Void
	{
		super();
		
		contentType = "text/html; charset=utf-8";
	}
}
