package ;

import Imports;

#if php
import php.FirePHP;
#end

class Main 
{
	static function main() 
	{
		#if php
			try
			{
				haquery.server.HaQuery.run();
			}
			catch (e:Dynamic)
			{
				haquery.server.HaQuery.traceException(e);
			}
		#end
 	}
}

