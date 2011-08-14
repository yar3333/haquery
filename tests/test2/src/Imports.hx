#if php
import haquery.components.button.Server;
import haquery.components.ckeditor.Server;
import haquery.components.list.Server;
import haquery.components.listitem.Server;
import pages.index.Server;
#else
import haquery.components.button.Client;
import haquery.components.ckeditor.Client;
import pages.index.Client;
#end