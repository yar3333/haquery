package components.macrotests.c;

import haquery.client.Lib;
import haquery.client.HaqComponent;

class Client extends HaqComponent
{
	@handler function a_checkA(t, e)
	{
		//t.
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