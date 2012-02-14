package haquery.server.io;

#if php
typedef FileOutput = php.io.FileOutput;
#elseif neko
typedef FileOutput = neko.io.FileOutput;
#end