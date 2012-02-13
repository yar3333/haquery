package components.set1.randnum;

import haquery.server.HaqComponent;

class Server extends HaqComponent
{
	public function preRender()
	{
		q('#n').html('123');
	}
}
