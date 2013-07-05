package haquery.common;

#if server
typedef BasePage = haquery.server.BasePage;
#elseif client
typedef BasePage = haquery.client.BasePage;
#end
