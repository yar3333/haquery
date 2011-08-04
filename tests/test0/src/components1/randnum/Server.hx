#if php
package components1.randnum;

import php.Lib;
import haquery.server.HaqComponent;

class Server extends HaqComponent
{
	public function preRender()
	{
		q('#n').html('123');
	}
}
#end
