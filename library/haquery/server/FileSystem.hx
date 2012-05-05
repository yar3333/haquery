package haquery.server;

#if php
typedef FileSystem = php.FileSystem;
#elseif neko
typedef FileSystem = neko.FileSystem;
#elseif cpp
typedef FileSystem = cpp.FileSystem;
#end