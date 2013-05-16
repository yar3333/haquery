package haquery.common;

#if server
typedef BasePage = haquery.server.HaqPage;
#else
typedef BasePage = haquery.client.HaqPage;
#end

class Generated
{
	public static inline var staticUrlPrefix = "";
}