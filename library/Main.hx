import Imports;

class Main 
{
	static function main() 
	{
		#if server
			
			#if !HXFCGI
				
				#if php
					
					haquery.server.Lib.run();
					
				#elseif neko
					
					neko.Web.cacheModule(haquery.server.Lib.run);
					haquery.server.Lib.run();
					
				#end
				
			#else
				
				neko.Web.cacheModule(function()
				{
					haquery.server.Lib.run();
				});
				
			#end
			
		#end
 	}
}
