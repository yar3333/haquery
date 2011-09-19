import Imports;

class Main $(CSLB){
	static function main() $(CSLB){
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

