package components.macrotests.c;

import haquery.server.Lib;
import haquery.server.HaqComponent;

class Server extends HaqComponent
{
	@handler function a_checkA(t, e)
	{
		//e.
	}
	
	@handler function b_checkB(t, e)
	{
		//e.
	}
	
	@handler function b_checkA(t, e)
	{
		//e.zzz;
	}
}