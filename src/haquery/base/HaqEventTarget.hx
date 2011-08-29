package haquery.base;

#if php
	import haquery.server.HaqComponent;
    import haquery.server.HaqQuery;
#else
	import haquery.client.HaqComponent;
    import haquery.client.HaqQuery;
#end

enum HaqEventTarget
{
    component(t:HaqComponent);
    elem(t:HaqQuery);
}
