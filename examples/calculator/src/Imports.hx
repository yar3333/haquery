#if php
import haquery.components.button.Server;
import haquery.components.ckeditor.Server;
import haquery.components.codemirror.Server;
import haquery.components.consts.Server;
import haquery.components.list.Server;
import haquery.components.listitem.Server;
import haquery.components.splitter.Server;
import haquery.components.tabs.Server;
import components.button.Server;
import components.joke.Server;
import pages.Bootstrap;
#else
import haquery.components.button.Client;
import haquery.components.ckeditor.Client;
import haquery.components.codemirror.Client;
import haquery.components.listitem.Client;
import haquery.components.splitter.Client;
import haquery.components.tabs.Client;
import components.button.Client;
import components.calculator.Client;
import pages.index.Client;
#end