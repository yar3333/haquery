package haquery.server;

#if php
typedef Sys = php.Sys;
#elseif neko
typedef Sys = neko.Sys;
#elseif cpp
typedef Sys = cpp.Sys;
#end