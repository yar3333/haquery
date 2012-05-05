package haquery.server.io;

#if php
typedef Path = php.io.Path;
#elseif neko
typedef Path = neko.io.Path;
#elseif cpp
typedef Path = cpp.io.Path;
#end