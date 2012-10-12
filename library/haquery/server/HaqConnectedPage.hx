package haquery.server;

import haquery.server.db.HaqDb;
import sys.net.WebSocket;

typedef HaqConnectedPage = 
{
	var page : HaqPage;
	var config : HaqConfig;
	var db : HaqDb;
	var ws : WebSocket;
}
