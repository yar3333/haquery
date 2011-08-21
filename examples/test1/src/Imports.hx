#if php
import haquery.components.button.Server;
import haquery.components.ckeditor.Server;
import haquery.components.list.Server;
import haquery.components.listitem.Server;
import components.button.Server;
import components.joke.Server;
import components.list.Server;
import components.listitem.Server;
import pages.Bootstrap;
import pages.test.Server;
#else
import haquery.components.button.Client;
import haquery.components.ckeditor.Client;
import components.button.Client;
import components.calculator.Client;
import pages.index.Client;
import pages.test.Client;
#end