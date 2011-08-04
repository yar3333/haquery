#if php
import components.button.Server;
import components.joke.Server;
import components.list.Server;
import components.listitem.Server;
import pages.Bootstrap;
import pages.test.Server;
#else
import components.button.Client;
import components.calculator.Client;
import pages.index.Client;
import pages.test.Client;
#end