package haquery.tools;

using haquery.StringTools;

class PackageTree 
{
	var children(default, null) : Hash<PackageTree>;
	
	public function new(packages:Array<String>) 
	{
		children = new Hash<PackageTree>();
		
		for (pack in packages)
		{
			add(pack);
		}
	}
	
	public function add(s:String)
	{
		var n = s.indexOf(".");
		if (n < 0)
		{
			children.set(s, null);
		}
		else
		{
			var name = s.substr(0, n);
			if (!children.exists(name))
			{
				children.set(name, new PackageTree([ s.substr(n + 1) ]));
			}
			else
			{
				children.get(name).add(s.substr(n + 1));
			}
		}
	}
	
	public function toString()
	{
		var paths = Lambda.map({ iterator:children.keys }, function(name)
		{
			var child = children.get(name);
			if (child == null)
			{
				return name;
			}
			else
			{
				return name + "/" + child.toString();
			}
		});
		
		return paths.length <= 1 ? paths.join("|") : "(?:" + paths.join("|") + ")";
	}
}