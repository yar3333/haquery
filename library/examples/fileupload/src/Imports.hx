// ../../src
#if php
import haquery.components.button.Server;
import haquery.components.ckeditor.Server;
import haquery.components.codemirror.Server;
import haquery.components.consts.Server;
import haquery.components.container.Server;
import haquery.components.contextpanel.Server;
import haquery.components.link.Server;
import haquery.components.list.Server;
import haquery.components.listitem.Server;
import haquery.components.splitter.Server;
import haquery.components.tabs.Server;
import haquery.components.uploader.Server;
import haquery.components.urlmenu.Server;
#else
import haquery.components.button.Client;
import haquery.components.ckeditor.Client;
import haquery.components.codemirror.Client;
import haquery.components.container.Client;
import haquery.components.contextpanel.Client;
import haquery.components.link.Client;
import haquery.components.listitem.Client;
import haquery.components.splitter.Client;
import haquery.components.tabs.Client;
import haquery.components.uploader.Client;
import haquery.components.urlmenu.Client;
#end

// src
#if php
import pages.Bootstrap;
import pages.index.Server;
#else
import pages.index.Client;
#end

