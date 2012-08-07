package haquery.tools;

import haquery.Std;

enum ValueType
{
	true_(name:String);
	false_(name:String);
	int(name:String);
	float(name:String);
	string(name:String);
	bool(name:String);
}

private typedef TAction = 
{
	var switches : Array<String>;
	var action : ValueType;
	var help : String;
}

class CommandLineOptionsParser
{
	public var options(default, null) : Hash<Dynamic>;
	public var params : Array<String>;
	
	var actions : Array<TAction>;
	var args : Array<String>;

	public function new()
	{
		actions = new Array();
	}

	public function getHelpMessage() : String
	{
		var s = "";
		for (a in actions)
		{
			s += a.switches.join(", ");
			if (a.switches.length > 1)
			{
				s += "\n";
			}
			if (a.help != null) 
			{
				s += "\t" + a.help;
			}
			s += "\n";
		}
		s += "\n";
		return s;
	}

	public function addOption(switches:Array<String>, action:ValueType, ?help:String)
	{
		for (a in actions)
		{
			for(s in a.switches)
			{
				if (Lambda.has(switches, s))
				{
					throw "Switch '" + s + "' already added.";
				}
			}
		}
		
		actions.push( { switches : switches, action : action, help : help } );
	}

	public function parse(args:Array<String>) : Void
	{
		if (args.length != null)
		{
			this.args = args.copy();
			options = new Hash<Dynamic>();
			params = new Array<String>();
			while (args.length > 0)
			{
				parseElement();
			}
		}
	}

	function parseElement()
	{
		var arg = args.shift();
		
		if (arg.substr(0, 1) == "-")
		{
			~/((?:--*).+)=(.+)/.customReplace(arg, function(r)
			{
				arg = r.matched(1);
				args.unshift(r.matched(2));
				return "";
			});
			
			for (a in actions)
			{
				for (s in a.switches)
				{
					if (s == arg)
					{
						resolveSwitch(arg, a.action);
					}
					else
					{
						if (s == arg.substr(0, s.length))
						{
							args.unshift(arg.substr(s.length));
							resolveSwitch(s, a.action);
						}
					}
				}
			}
		}
		else
		{
			params.push(arg);
		}
	}

	function resolveSwitch(s:String, type:ValueType) : Void
	{
		switch (type)
		{
			case ValueType.true_(name):
				options.set(name, true);
			
			case ValueType.false_(name):
				options.set(name, false);
			
			case ValueType.int(name):
				ensureValueExist(s);
				options.set(name, Std.parseInt(suppressQuotes(args.shift())));
				
			case ValueType.float(name):
				ensureValueExist(s);
				options.set(name, Std.parseFloat(suppressQuotes(args.shift())));
				
			case ValueType.string(name):
				ensureValueExist(s);
				options.set(name, suppressQuotes(args.shift()));
				
			case ValueType.bool(name):
				ensureValueExist(s);
				options.set(name, Std.bool(suppressQuotes(args.shift())));
		}
	}
	
	function ensureValueExist(s:String) : Void
	{
		if (args.length == 0)
		{
			throw "Missing value after '" + s + "' switch.";
		}
	}
	
	function suppressQuotes(s:String) : String
	{
		s = ~/'(.+)'/g.replace( s, "$1" );
		s = ~/"(.+)"/g.replace( s, "$1" );
		return s;
	}
}