package haquery.server;

#if php
typedef FileSystem = php.FileSystem;
#elseif neko
typedef FileSystem = neko.FileSystem;
#end