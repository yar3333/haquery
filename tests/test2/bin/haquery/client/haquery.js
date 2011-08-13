$estr = function() { return js.Boot.__string_rec(this,''); }
if(typeof haxe=='undefined') haxe = {}
haxe.StackItem = { __ename__ : ["haxe","StackItem"], __constructs__ : ["CFunction","Module","FilePos","Method","Lambda"] }
haxe.StackItem.CFunction = ["CFunction",0];
haxe.StackItem.CFunction.toString = $estr;
haxe.StackItem.CFunction.__enum__ = haxe.StackItem;
haxe.StackItem.Module = function(m) { var $x = ["Module",1,m]; $x.__enum__ = haxe.StackItem; $x.toString = $estr; return $x; }
haxe.StackItem.FilePos = function(s,file,line) { var $x = ["FilePos",2,s,file,line]; $x.__enum__ = haxe.StackItem; $x.toString = $estr; return $x; }
haxe.StackItem.Method = function(classname,method) { var $x = ["Method",3,classname,method]; $x.__enum__ = haxe.StackItem; $x.toString = $estr; return $x; }
haxe.StackItem.Lambda = function(v) { var $x = ["Lambda",4,v]; $x.__enum__ = haxe.StackItem; $x.toString = $estr; return $x; }
haxe.Stack = function() { }
haxe.Stack.__name__ = ["haxe","Stack"];
haxe.Stack.callStack = function() {
	$s.push("haxe.Stack::callStack");
	var $spos = $s.length;
	var $tmp = haxe.Stack.makeStack("$s");
	$s.pop();
	return $tmp;
	$s.pop();
}
haxe.Stack.exceptionStack = function() {
	$s.push("haxe.Stack::exceptionStack");
	var $spos = $s.length;
	var $tmp = haxe.Stack.makeStack("$e");
	$s.pop();
	return $tmp;
	$s.pop();
}
haxe.Stack.toString = function(stack) {
	$s.push("haxe.Stack::toString");
	var $spos = $s.length;
	var b = new StringBuf();
	var _g = 0;
	while(_g < stack.length) {
		var s = stack[_g];
		++_g;
		b.b[b.b.length] = "\nCalled from ";
		haxe.Stack.itemToString(b,s);
	}
	var $tmp = b.b.join("");
	$s.pop();
	return $tmp;
	$s.pop();
}
haxe.Stack.itemToString = function(b,s) {
	$s.push("haxe.Stack::itemToString");
	var $spos = $s.length;
	var $e = (s);
	switch( $e[1] ) {
	case 0:
		b.b[b.b.length] = "a C function";
		break;
	case 1:
		var m = $e[2];
		b.b[b.b.length] = "module ";
		b.b[b.b.length] = m;
		break;
	case 2:
		var line = $e[4], file = $e[3], s1 = $e[2];
		if(s1 != null) {
			haxe.Stack.itemToString(b,s1);
			b.b[b.b.length] = " (";
		}
		b.b[b.b.length] = file;
		b.b[b.b.length] = " line ";
		b.b[b.b.length] = line;
		if(s1 != null) b.b[b.b.length] = ")";
		break;
	case 3:
		var meth = $e[3], cname = $e[2];
		b.b[b.b.length] = cname;
		b.b[b.b.length] = ".";
		b.b[b.b.length] = meth;
		break;
	case 4:
		var n = $e[2];
		b.b[b.b.length] = "local function #";
		b.b[b.b.length] = n;
		break;
	}
	$s.pop();
}
haxe.Stack.makeStack = function(s) {
	$s.push("haxe.Stack::makeStack");
	var $spos = $s.length;
	var a = (function($this) {
		var $r;
		try {
			$r = eval(s);
		} catch( e ) {
			$r = (function($this) {
				var $r;
				$e = [];
				while($s.length >= $spos) $e.unshift($s.pop());
				$s.push($e[0]);
				$r = [];
				return $r;
			}($this));
		}
		return $r;
	}(this));
	var m = new Array();
	var _g1 = 0, _g = a.length - (s == "$s"?2:0);
	while(_g1 < _g) {
		var i = _g1++;
		var d = a[i].split("::");
		m.unshift(haxe.StackItem.Method(d[0],d[1]));
	}
	$s.pop();
	return m;
	$s.pop();
}
haxe.Stack.prototype.__class__ = haxe.Stack;
StringTools = function() { }
StringTools.__name__ = ["StringTools"];
StringTools.urlEncode = function(s) {
	$s.push("StringTools::urlEncode");
	var $spos = $s.length;
	var $tmp = encodeURIComponent(s);
	$s.pop();
	return $tmp;
	$s.pop();
}
StringTools.urlDecode = function(s) {
	$s.push("StringTools::urlDecode");
	var $spos = $s.length;
	var $tmp = decodeURIComponent(s.split("+").join(" "));
	$s.pop();
	return $tmp;
	$s.pop();
}
StringTools.htmlEscape = function(s) {
	$s.push("StringTools::htmlEscape");
	var $spos = $s.length;
	var $tmp = s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
	$s.pop();
	return $tmp;
	$s.pop();
}
StringTools.htmlUnescape = function(s) {
	$s.push("StringTools::htmlUnescape");
	var $spos = $s.length;
	var $tmp = s.split("&gt;").join(">").split("&lt;").join("<").split("&amp;").join("&");
	$s.pop();
	return $tmp;
	$s.pop();
}
StringTools.startsWith = function(s,start) {
	$s.push("StringTools::startsWith");
	var $spos = $s.length;
	var $tmp = s.length >= start.length && s.substr(0,start.length) == start;
	$s.pop();
	return $tmp;
	$s.pop();
}
StringTools.endsWith = function(s,end) {
	$s.push("StringTools::endsWith");
	var $spos = $s.length;
	var elen = end.length;
	var slen = s.length;
	var $tmp = slen >= elen && s.substr(slen - elen,elen) == end;
	$s.pop();
	return $tmp;
	$s.pop();
}
StringTools.isSpace = function(s,pos) {
	$s.push("StringTools::isSpace");
	var $spos = $s.length;
	var c = s.charCodeAt(pos);
	var $tmp = c >= 9 && c <= 13 || c == 32;
	$s.pop();
	return $tmp;
	$s.pop();
}
StringTools.ltrim = function(s) {
	$s.push("StringTools::ltrim");
	var $spos = $s.length;
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,r)) r++;
	if(r > 0) {
		var $tmp = s.substr(r,l - r);
		$s.pop();
		return $tmp;
	} else {
		$s.pop();
		return s;
	}
	$s.pop();
}
StringTools.rtrim = function(s) {
	$s.push("StringTools::rtrim");
	var $spos = $s.length;
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,l - r - 1)) r++;
	if(r > 0) {
		var $tmp = s.substr(0,l - r);
		$s.pop();
		return $tmp;
	} else {
		$s.pop();
		return s;
	}
	$s.pop();
}
StringTools.trim = function(s) {
	$s.push("StringTools::trim");
	var $spos = $s.length;
	var $tmp = StringTools.ltrim(StringTools.rtrim(s));
	$s.pop();
	return $tmp;
	$s.pop();
}
StringTools.rpad = function(s,c,l) {
	$s.push("StringTools::rpad");
	var $spos = $s.length;
	var sl = s.length;
	var cl = c.length;
	while(sl < l) if(l - sl < cl) {
		s += c.substr(0,l - sl);
		sl = l;
	} else {
		s += c;
		sl += cl;
	}
	$s.pop();
	return s;
	$s.pop();
}
StringTools.lpad = function(s,c,l) {
	$s.push("StringTools::lpad");
	var $spos = $s.length;
	var ns = "";
	var sl = s.length;
	if(sl >= l) {
		$s.pop();
		return s;
	}
	var cl = c.length;
	while(sl < l) if(l - sl < cl) {
		ns += c.substr(0,l - sl);
		sl = l;
	} else {
		ns += c;
		sl += cl;
	}
	var $tmp = ns + s;
	$s.pop();
	return $tmp;
	$s.pop();
}
StringTools.replace = function(s,sub,by) {
	$s.push("StringTools::replace");
	var $spos = $s.length;
	var $tmp = s.split(sub).join(by);
	$s.pop();
	return $tmp;
	$s.pop();
}
StringTools.hex = function(n,digits) {
	$s.push("StringTools::hex");
	var $spos = $s.length;
	var s = "";
	var hexChars = "0123456789ABCDEF";
	do {
		s = hexChars.charAt(n & 15) + s;
		n >>>= 4;
	} while(n > 0);
	if(digits != null) while(s.length < digits) s = "0" + s;
	$s.pop();
	return s;
	$s.pop();
}
StringTools.fastCodeAt = function(s,index) {
	$s.push("StringTools::fastCodeAt");
	var $spos = $s.length;
	var $tmp = s.cca(index);
	$s.pop();
	return $tmp;
	$s.pop();
}
StringTools.isEOF = function(c) {
	$s.push("StringTools::isEOF");
	var $spos = $s.length;
	var $tmp = c != c;
	$s.pop();
	return $tmp;
	$s.pop();
}
StringTools.prototype.__class__ = StringTools;
Reflect = function() { }
Reflect.__name__ = ["Reflect"];
Reflect.hasField = function(o,field) {
	$s.push("Reflect::hasField");
	var $spos = $s.length;
	if(o.hasOwnProperty != null) {
		var $tmp = o.hasOwnProperty(field);
		$s.pop();
		return $tmp;
	}
	var arr = Reflect.fields(o);
	var $it0 = arr.iterator();
	while( $it0.hasNext() ) {
		var t = $it0.next();
		if(t == field) {
			$s.pop();
			return true;
		}
	}
	$s.pop();
	return false;
	$s.pop();
}
Reflect.field = function(o,field) {
	$s.push("Reflect::field");
	var $spos = $s.length;
	var v = null;
	try {
		v = o[field];
	} catch( e ) {
		$e = [];
		while($s.length >= $spos) $e.unshift($s.pop());
		$s.push($e[0]);
	}
	$s.pop();
	return v;
	$s.pop();
}
Reflect.setField = function(o,field,value) {
	$s.push("Reflect::setField");
	var $spos = $s.length;
	o[field] = value;
	$s.pop();
}
Reflect.callMethod = function(o,func,args) {
	$s.push("Reflect::callMethod");
	var $spos = $s.length;
	var $tmp = func.apply(o,args);
	$s.pop();
	return $tmp;
	$s.pop();
}
Reflect.fields = function(o) {
	$s.push("Reflect::fields");
	var $spos = $s.length;
	if(o == null) {
		var $tmp = new Array();
		$s.pop();
		return $tmp;
	}
	var a = new Array();
	if(o.hasOwnProperty) {
		for(var i in o) if( o.hasOwnProperty(i) ) a.push(i);
	} else {
		var t;
		try {
			t = o.__proto__;
		} catch( e ) {
			$e = [];
			while($s.length >= $spos) $e.unshift($s.pop());
			$s.push($e[0]);
			t = null;
		}
		if(t != null) o.__proto__ = null;
		for(var i in o) if( i != "__proto__" ) a.push(i);
		if(t != null) o.__proto__ = t;
	}
	$s.pop();
	return a;
	$s.pop();
}
Reflect.isFunction = function(f) {
	$s.push("Reflect::isFunction");
	var $spos = $s.length;
	var $tmp = typeof(f) == "function" && f.__name__ == null;
	$s.pop();
	return $tmp;
	$s.pop();
}
Reflect.compare = function(a,b) {
	$s.push("Reflect::compare");
	var $spos = $s.length;
	var $tmp = a == b?0:a > b?1:-1;
	$s.pop();
	return $tmp;
	$s.pop();
}
Reflect.compareMethods = function(f1,f2) {
	$s.push("Reflect::compareMethods");
	var $spos = $s.length;
	if(f1 == f2) {
		$s.pop();
		return true;
	}
	if(!Reflect.isFunction(f1) || !Reflect.isFunction(f2)) {
		$s.pop();
		return false;
	}
	var $tmp = f1.scope == f2.scope && f1.method == f2.method && f1.method != null;
	$s.pop();
	return $tmp;
	$s.pop();
}
Reflect.isObject = function(v) {
	$s.push("Reflect::isObject");
	var $spos = $s.length;
	if(v == null) {
		$s.pop();
		return false;
	}
	var t = typeof(v);
	var $tmp = t == "string" || t == "object" && !v.__enum__ || t == "function" && v.__name__ != null;
	$s.pop();
	return $tmp;
	$s.pop();
}
Reflect.deleteField = function(o,f) {
	$s.push("Reflect::deleteField");
	var $spos = $s.length;
	if(!Reflect.hasField(o,f)) {
		$s.pop();
		return false;
	}
	delete(o[f]);
	$s.pop();
	return true;
	$s.pop();
}
Reflect.copy = function(o) {
	$s.push("Reflect::copy");
	var $spos = $s.length;
	var o2 = { };
	var _g = 0, _g1 = Reflect.fields(o);
	while(_g < _g1.length) {
		var f = _g1[_g];
		++_g;
		o2[f] = Reflect.field(o,f);
	}
	$s.pop();
	return o2;
	$s.pop();
}
Reflect.makeVarArgs = function(f) {
	$s.push("Reflect::makeVarArgs");
	var $spos = $s.length;
	var $tmp = function() {
		$s.push("Reflect::makeVarArgs@108");
		var $spos = $s.length;
		var a = new Array();
		var _g1 = 0, _g = arguments.length;
		while(_g1 < _g) {
			var i = _g1++;
			a.push(arguments[i]);
		}
		var $tmp = f(a);
		$s.pop();
		return $tmp;
		$s.pop();
	};
	$s.pop();
	return $tmp;
	$s.pop();
}
Reflect.hasMethod = function(o,field) {
	$s.push("Reflect::hasMethod");
	var $spos = $s.length;
	var $tmp = eval('typeof o.'+field)=='function';
	$s.pop();
	return $tmp;
	$s.pop();
}
Reflect.prototype.__class__ = Reflect;
haxe.Log = function() { }
haxe.Log.__name__ = ["haxe","Log"];
haxe.Log.trace = function(v,infos) {
	$s.push("haxe.Log::trace");
	var $spos = $s.length;
	js.Boot.__trace(v,infos);
	$s.pop();
}
haxe.Log.clear = function() {
	$s.push("haxe.Log::clear");
	var $spos = $s.length;
	js.Boot.__clear_trace();
	$s.pop();
}
haxe.Log.prototype.__class__ = haxe.Log;
if(typeof haquery=='undefined') haquery = {}
if(!haquery.base) haquery.base = {}
haquery.base.HaQuery = function() { }
haquery.base.HaQuery.__name__ = ["haquery","base","HaQuery"];
haquery.base.HaQuery.run = function() {
	$s.push("haquery.base.HaQuery::run");
	var $spos = $s.length;
	if(haxe.Firebug.detect()) haxe.Firebug.redirectTraces();
	var system = new haquery.client.HaqSystem();
	$s.pop();
}
haquery.base.HaQuery.redirect = function(url) {
	$s.push("haquery.base.HaQuery::redirect");
	var $spos = $s.length;
	if(url == js.Lib.window.location.href) js.Lib.window.location.reload(true); else js.Lib.window.location.href = url;
	$s.pop();
}
haquery.base.HaQuery.reload = function() {
	$s.push("haquery.base.HaQuery::reload");
	var $spos = $s.length;
	js.Lib.window.location.reload(true);
	$s.pop();
}
haquery.base.HaQuery.assert = function(e,errorMessage,pos) {
	$s.push("haquery.base.HaQuery::assert");
	var $spos = $s.length;
	if(!e) {
		if(errorMessage == null) errorMessage = "ASSERT";
		throw errorMessage + " in " + pos.fileName + " at line " + pos.lineNumber;
	}
	$s.pop();
}
haquery.base.HaQuery.prototype.__class__ = haquery.base.HaQuery;
StringBuf = function(p) {
	if( p === $_ ) return;
	$s.push("StringBuf::new");
	var $spos = $s.length;
	this.b = new Array();
	$s.pop();
}
StringBuf.__name__ = ["StringBuf"];
StringBuf.prototype.add = function(x) {
	$s.push("StringBuf::add");
	var $spos = $s.length;
	this.b[this.b.length] = x;
	$s.pop();
}
StringBuf.prototype.addSub = function(s,pos,len) {
	$s.push("StringBuf::addSub");
	var $spos = $s.length;
	this.b[this.b.length] = s.substr(pos,len);
	$s.pop();
}
StringBuf.prototype.addChar = function(c) {
	$s.push("StringBuf::addChar");
	var $spos = $s.length;
	this.b[this.b.length] = String.fromCharCode(c);
	$s.pop();
}
StringBuf.prototype.toString = function() {
	$s.push("StringBuf::toString");
	var $spos = $s.length;
	var $tmp = this.b.join("");
	$s.pop();
	return $tmp;
	$s.pop();
}
StringBuf.prototype.b = null;
StringBuf.prototype.__class__ = StringBuf;
haquery.base.HaqComponent = function(p) {
	if( p === $_ ) return;
	$s.push("haquery.base.HaqComponent::new");
	var $spos = $s.length;
	this.components = new Hash();
	this.nextAnonimID = 0;
	$s.pop();
}
haquery.base.HaqComponent.__name__ = ["haquery","base","HaqComponent"];
haquery.base.HaqComponent.prototype.manager = null;
haquery.base.HaqComponent.prototype.id = null;
haquery.base.HaqComponent.prototype.parent = null;
haquery.base.HaqComponent.prototype.tag = null;
haquery.base.HaqComponent.prototype.fullID = null;
haquery.base.HaqComponent.prototype.prefixID = null;
haquery.base.HaqComponent.prototype.components = null;
haquery.base.HaqComponent.prototype.nextAnonimID = null;
haquery.base.HaqComponent.prototype.commonConstruct = function(manager,parent,tag,id) {
	$s.push("haquery.base.HaqComponent::commonConstruct");
	var $spos = $s.length;
	if(id == null || id == "") id = parent != null?parent.getNextAnonimID():"";
	this.manager = manager;
	this.parent = parent;
	this.tag = tag;
	this.id = id;
	this.fullID = (parent != null?parent.prefixID:"") + id;
	this.prefixID = this.fullID != ""?this.fullID + "-":"";
	if(parent != null) {
		haquery.base.HaQuery.assert(!parent.components.exists(id),"Component with same id '" + id + "' already exist.",{ fileName : "HaqComponent.hx", lineNumber : 76, className : "haquery.base.HaqComponent", methodName : "commonConstruct"});
		parent.components.set(id,(function($this) {
			var $r;
			var $t = $this;
			if(Std["is"]($t,haquery.client.HaqComponent)) $t; else throw "Class cast error";
			$r = $t;
			return $r;
		}(this)));
	}
	$s.pop();
}
haquery.base.HaqComponent.prototype.createEvents = function() {
	$s.push("haquery.base.HaqComponent::createEvents");
	var $spos = $s.length;
	if(this.parent != null) {
		var _g = 0, _g1 = Type.getInstanceFields(Type.getClass(this));
		while(_g < _g1.length) {
			var field = _g1[_g];
			++_g;
			if(StringTools.startsWith(field,"event_")) {
				var event = Reflect.field(this,field);
				if(event == null) {
					event = new haquery.base.HaqEvent((function($this) {
						var $r;
						var $t = $this;
						if(Std["is"]($t,haquery.client.HaqComponent)) $t; else throw "Class cast error";
						$r = $t;
						return $r;
					}(this)),field.substr("event_".length));
					this[field] = event;
				}
				this.parent.connectEventHandlers((function($this) {
					var $r;
					var $t = $this;
					if(Std["is"]($t,haquery.client.HaqComponent)) $t; else throw "Class cast error";
					$r = $t;
					return $r;
				}(this)),event);
			}
		}
	}
	$s.pop();
}
haquery.base.HaqComponent.prototype.connectEventHandlers = function(child,event) {
	$s.push("haquery.base.HaqComponent::connectEventHandlers");
	var $spos = $s.length;
	var handlerName = child.id + "_" + event.name;
	if(Reflect.hasMethod(this,handlerName)) event.bind((function($this) {
		var $r;
		var $t = $this;
		if(Std["is"]($t,haquery.client.HaqComponent)) $t; else throw "Class cast error";
		$r = $t;
		return $r;
	}(this)),Reflect.field(this,handlerName));
	$s.pop();
}
haquery.base.HaqComponent.prototype.forEachComponent = function(f,isFromTopToBottom) {
	$s.push("haquery.base.HaqComponent::forEachComponent");
	var $spos = $s.length;
	if(isFromTopToBottom == null) isFromTopToBottom = true;
	if(isFromTopToBottom && Reflect.hasMethod(this,f)) Reflect.field(this,f).apply(this,[]);
	var $it0 = this.components.iterator();
	while( $it0.hasNext() ) {
		var component = $it0.next();
		component.forEachComponent(f,isFromTopToBottom);
	}
	if(!isFromTopToBottom && Reflect.hasMethod(this,f)) Reflect.field(this,f).apply(this,[]);
	$s.pop();
}
haquery.base.HaqComponent.prototype.findComponent = function(fullID) {
	$s.push("haquery.base.HaqComponent::findComponent");
	var $spos = $s.length;
	if(fullID == "") {
		var $tmp = (function($this) {
			var $r;
			var $t = $this;
			if(Std["is"]($t,haquery.client.HaqComponent)) $t; else throw "Class cast error";
			$r = $t;
			return $r;
		}(this));
		$s.pop();
		return $tmp;
	}
	var ids = fullID.split("-");
	var r = this;
	var _g = 0;
	while(_g < ids.length) {
		var id = ids[_g];
		++_g;
		if(!r.components.exists(id)) {
			$s.pop();
			return null;
		}
		r = r.components.get(id);
	}
	var $tmp = (function($this) {
		var $r;
		var $t = r;
		if(Std["is"]($t,haquery.client.HaqComponent)) $t; else throw "Class cast error";
		$r = $t;
		return $r;
	}(this));
	$s.pop();
	return $tmp;
	$s.pop();
}
haquery.base.HaqComponent.prototype.getNextAnonimID = function() {
	$s.push("haquery.base.HaqComponent::getNextAnonimID");
	var $spos = $s.length;
	this.nextAnonimID++;
	var $tmp = "haqc_" + Std.string(this.nextAnonimID);
	$s.pop();
	return $tmp;
	$s.pop();
}
haquery.base.HaqComponent.prototype.__class__ = haquery.base.HaqComponent;
if(!haquery.client) haquery.client = {}
haquery.client.HaqComponent = function(p) {
	if( p === $_ ) return;
	$s.push("haquery.client.HaqComponent::new");
	var $spos = $s.length;
	haquery.base.HaqComponent.call(this);
	$s.pop();
}
haquery.client.HaqComponent.__name__ = ["haquery","client","HaqComponent"];
haquery.client.HaqComponent.__super__ = haquery.base.HaqComponent;
for(var k in haquery.base.HaqComponent.prototype ) haquery.client.HaqComponent.prototype[k] = haquery.base.HaqComponent.prototype[k];
haquery.client.HaqComponent.prototype.construct = function(manager,parent,tag,id) {
	$s.push("haquery.client.HaqComponent::construct");
	var $spos = $s.length;
	haquery.base.HaqComponent.prototype.commonConstruct.call(this,manager,parent,tag,id);
	this.createEvents();
	this.createChildComponents();
	if(Reflect.hasMethod(this,"init")) Reflect.field(this,"init").apply(this,[]);
	$s.pop();
}
haquery.client.HaqComponent.prototype.createChildComponents = function() {
	$s.push("haquery.client.HaqComponent::createChildComponents");
	var $spos = $s.length;
	var childComponentsData = this.manager.getChildComponents(this);
	var _g = 0;
	while(_g < childComponentsData.length) {
		var component = childComponentsData[_g];
		++_g;
		this.manager.createComponent(this,component.tag,component.id);
	}
	$s.pop();
}
haquery.client.HaqComponent.prototype.q = function(selector,base) {
	$s.push("haquery.client.HaqComponent::q");
	var $spos = $s.length;
	if(selector != null && Type.getClassName(Type.getClass(selector)) == "String" && this.prefixID != "") selector = StringTools.replace(selector,"#","#" + this.prefixID);
	var $tmp = new $(selector,base);
	$s.pop();
	return $tmp;
	$s.pop();
}
haquery.client.HaqComponent.prototype.__class__ = haquery.client.HaqComponent;
haquery.client.HaqComponentManager = function(templates,id_tag) {
	if( templates === $_ ) return;
	$s.push("haquery.client.HaqComponentManager::new");
	var $spos = $s.length;
	this.templates = templates;
	this.id_tag = id_tag;
	$s.pop();
}
haquery.client.HaqComponentManager.__name__ = ["haquery","client","HaqComponentManager"];
haquery.client.HaqComponentManager.prototype.templates = null;
haquery.client.HaqComponentManager.prototype.id_tag = null;
haquery.client.HaqComponentManager.prototype.createComponent = function(parent,tag,id) {
	$s.push("haquery.client.HaqComponentManager::createComponent");
	var $spos = $s.length;
	var clas;
	if(parent != null) clas = this.templates.get(tag).clas; else {
		var pagePath = js.Lib.window.location.pathname.trim("/");
		if(pagePath == "") pagePath = "index";
		var className = "pages." + pagePath.replaceAll("/",".") + ".Client";
		clas = Type.resolveClass(className);
		if(clas == null) clas = Type.resolveClass("haquery.client.HaqPage");
	}
	var component = Type.createInstance(clas,[]);
	if(Reflect.hasMethod(component,"construct")) component.construct(this,parent,tag,id); else throw "Component client class '" + Type.getClassName(clas) + "' must be inherited from class 'haquery.client.HaqComponent'.";
	$s.pop();
	return component;
	$s.pop();
}
haquery.client.HaqComponentManager.prototype.createPage = function() {
	$s.push("haquery.client.HaqComponentManager::createPage");
	var $spos = $s.length;
	var $tmp = (function($this) {
		var $r;
		var $t = $this.createComponent(null,"","");
		if(Std["is"]($t,haquery.client.HaqPage)) $t; else throw "Class cast error";
		$r = $t;
		return $r;
	}(this));
	$s.pop();
	return $tmp;
	$s.pop();
}
haquery.client.HaqComponentManager.prototype.getChildComponents = function(parent) {
	$s.push("haquery.client.HaqComponentManager::getChildComponents");
	var $spos = $s.length;
	var r = new Array();
	var re = new EReg("^" + parent.prefixID + "[^" + "-" + "]+$","");
	var $it0 = this.id_tag.keys();
	while( $it0.hasNext() ) {
		var fullID = $it0.next();
		if(re.match(fullID)) r.push({ id : fullID.substr(parent.prefixID.length), tag : this.id_tag.get(fullID)});
	}
	$s.pop();
	return r;
	$s.pop();
}
haquery.client.HaqComponentManager.prototype.__class__ = haquery.client.HaqComponentManager;
haquery.client.HaqInternals = function() { }
haquery.client.HaqInternals.__name__ = ["haquery","client","HaqInternals"];
haquery.client.HaqInternals.componentsFolders = null;
haquery.client.HaqInternals.serverHandlers = null;
haquery.client.HaqInternals.tags = null;
haquery.client.HaqInternals.lists = null;
haquery.client.HaqInternals.id_tag = null;
haquery.client.HaqInternals.id_tag_cached = null;
haquery.client.HaqInternals.id_tag_getter = function() {
	$s.push("haquery.client.HaqInternals::id_tag_getter");
	var $spos = $s.length;
	if(haquery.client.HaqInternals.id_tag_cached == null) {
		haquery.client.HaqInternals.id_tag_cached = new Hash();
		var _g = 0, _g1 = haquery.client.HaqInternals.tags;
		while(_g < _g1.length) {
			var tagAndIDs = _g1[_g];
			++_g;
			var tag = tagAndIDs[0];
			var ids = tagAndIDs[1].split(",");
			if(ids.length == 1 && ids[0] == "") ids = [];
			var _g2 = 0;
			while(_g2 < ids.length) {
				var id = ids[_g2];
				++_g2;
				haquery.client.HaqInternals.id_tag_cached.set(id,tag);
			}
		}
	}
	var $tmp = haquery.client.HaqInternals.id_tag_cached;
	$s.pop();
	return $tmp;
	$s.pop();
}
haquery.client.HaqInternals.prototype.__class__ = haquery.client.HaqInternals;
haxe.Firebug = function() { }
haxe.Firebug.__name__ = ["haxe","Firebug"];
haxe.Firebug.detect = function() {
	$s.push("haxe.Firebug::detect");
	var $spos = $s.length;
	try {
		var $tmp = console != null && console.error != null;
		$s.pop();
		return $tmp;
	} catch( e ) {
		$e = [];
		while($s.length >= $spos) $e.unshift($s.pop());
		$s.push($e[0]);
		$s.pop();
		return false;
	}
	$s.pop();
}
haxe.Firebug.redirectTraces = function() {
	$s.push("haxe.Firebug::redirectTraces");
	var $spos = $s.length;
	haxe.Log.trace = haxe.Firebug.trace;
	js.Lib.setErrorHandler(haxe.Firebug.onError);
	$s.pop();
}
haxe.Firebug.onError = function(err,stack) {
	$s.push("haxe.Firebug::onError");
	var $spos = $s.length;
	var buf = err + "\n";
	var _g = 0;
	while(_g < stack.length) {
		var s = stack[_g];
		++_g;
		buf += "Called from " + s + "\n";
	}
	haxe.Firebug.trace(buf,null);
	$s.pop();
	return true;
	$s.pop();
}
haxe.Firebug.trace = function(v,inf) {
	$s.push("haxe.Firebug::trace");
	var $spos = $s.length;
	var type = inf != null && inf.customParams != null?inf.customParams[0]:null;
	if(type != "warn" && type != "info" && type != "debug" && type != "error") type = inf == null?"error":"log";
	console[type]((inf == null?"":inf.fileName + ":" + inf.lineNumber + " : ") + Std.string(v));
	$s.pop();
}
haxe.Firebug.prototype.__class__ = haxe.Firebug;
IntIter = function(min,max) {
	if( min === $_ ) return;
	$s.push("IntIter::new");
	var $spos = $s.length;
	this.min = min;
	this.max = max;
	$s.pop();
}
IntIter.__name__ = ["IntIter"];
IntIter.prototype.min = null;
IntIter.prototype.max = null;
IntIter.prototype.hasNext = function() {
	$s.push("IntIter::hasNext");
	var $spos = $s.length;
	var $tmp = this.min < this.max;
	$s.pop();
	return $tmp;
	$s.pop();
}
IntIter.prototype.next = function() {
	$s.push("IntIter::next");
	var $spos = $s.length;
	var $tmp = this.min++;
	$s.pop();
	return $tmp;
	$s.pop();
}
IntIter.prototype.__class__ = IntIter;
haquery.client.HaqPage = function(p) {
	if( p === $_ ) return;
	$s.push("haquery.client.HaqPage::new");
	var $spos = $s.length;
	haquery.client.HaqComponent.call(this);
	$s.pop();
}
haquery.client.HaqPage.__name__ = ["haquery","client","HaqPage"];
haquery.client.HaqPage.__super__ = haquery.client.HaqComponent;
for(var k in haquery.client.HaqComponent.prototype ) haquery.client.HaqPage.prototype[k] = haquery.client.HaqComponent.prototype[k];
haquery.client.HaqPage.prototype.__class__ = haquery.client.HaqPage;
if(!haquery.components) haquery.components = {}
if(!haquery.components.button) haquery.components.button = {}
haquery.components.button.Client = function(p) {
	if( p === $_ ) return;
	$s.push("haquery.components.button.Client::new");
	var $spos = $s.length;
	haquery.client.HaqComponent.call(this);
	$s.pop();
}
haquery.components.button.Client.__name__ = ["haquery","components","button","Client"];
haquery.components.button.Client.__super__ = haquery.client.HaqComponent;
for(var k in haquery.client.HaqComponent.prototype ) haquery.components.button.Client.prototype[k] = haquery.client.HaqComponent.prototype[k];
haquery.components.button.Client.prototype.event_click = null;
haquery.components.button.Client.prototype.doClick = function() {
	$s.push("haquery.components.button.Client::doClick");
	var $spos = $s.length;
	this.q("#b").click();
	$s.pop();
}
haquery.components.button.Client.prototype.b_click = function() {
	$s.push("haquery.components.button.Client::b_click");
	var $spos = $s.length;
	var $tmp = this.event_click.call([this.isActive()]);
	$s.pop();
	return $tmp;
	$s.pop();
}
haquery.components.button.Client.prototype.setActive = function(isActive) {
	$s.push("haquery.components.button.Client::setActive");
	var $spos = $s.length;
	if(isActive) this.q("#b").addClass("active"); else this.q("#b").removeClass("active");
	$s.pop();
}
haquery.components.button.Client.prototype.isActive = function() {
	$s.push("haquery.components.button.Client::isActive");
	var $spos = $s.length;
	var $tmp = this.q("#b").hasClass("active");
	$s.pop();
	return $tmp;
	$s.pop();
}
haquery.components.button.Client.prototype.show = function() {
	$s.push("haquery.components.button.Client::show");
	var $spos = $s.length;
	this.q("#b").css("visibility","visible");
	$s.pop();
}
haquery.components.button.Client.prototype.__class__ = haquery.components.button.Client;
Std = function() { }
Std.__name__ = ["Std"];
Std["is"] = function(v,t) {
	$s.push("Std::is");
	var $spos = $s.length;
	var $tmp = js.Boot.__instanceof(v,t);
	$s.pop();
	return $tmp;
	$s.pop();
}
Std.string = function(s) {
	$s.push("Std::string");
	var $spos = $s.length;
	var $tmp = js.Boot.__string_rec(s,"");
	$s.pop();
	return $tmp;
	$s.pop();
}
Std["int"] = function(x) {
	$s.push("Std::int");
	var $spos = $s.length;
	if(x < 0) {
		var $tmp = Math.ceil(x);
		$s.pop();
		return $tmp;
	}
	var $tmp = Math.floor(x);
	$s.pop();
	return $tmp;
	$s.pop();
}
Std.parseInt = function(x) {
	$s.push("Std::parseInt");
	var $spos = $s.length;
	var v = parseInt(x,10);
	if(v == 0 && x.charCodeAt(1) == 120) v = parseInt(x);
	if(isNaN(v)) {
		$s.pop();
		return null;
	}
	var $tmp = v;
	$s.pop();
	return $tmp;
	$s.pop();
}
Std.parseFloat = function(x) {
	$s.push("Std::parseFloat");
	var $spos = $s.length;
	var $tmp = parseFloat(x);
	$s.pop();
	return $tmp;
	$s.pop();
}
Std.random = function(x) {
	$s.push("Std::random");
	var $spos = $s.length;
	var $tmp = Math.floor(Math.random() * x);
	$s.pop();
	return $tmp;
	$s.pop();
}
Std.prototype.__class__ = Std;
Lambda = function() { }
Lambda.__name__ = ["Lambda"];
Lambda.array = function(it) {
	$s.push("Lambda::array");
	var $spos = $s.length;
	var a = new Array();
	var $it0 = it.iterator();
	while( $it0.hasNext() ) {
		var i = $it0.next();
		a.push(i);
	}
	$s.pop();
	return a;
	$s.pop();
}
Lambda.list = function(it) {
	$s.push("Lambda::list");
	var $spos = $s.length;
	var l = new List();
	var $it0 = it.iterator();
	while( $it0.hasNext() ) {
		var i = $it0.next();
		l.add(i);
	}
	$s.pop();
	return l;
	$s.pop();
}
Lambda.map = function(it,f) {
	$s.push("Lambda::map");
	var $spos = $s.length;
	var l = new List();
	var $it0 = it.iterator();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		l.add(f(x));
	}
	$s.pop();
	return l;
	$s.pop();
}
Lambda.mapi = function(it,f) {
	$s.push("Lambda::mapi");
	var $spos = $s.length;
	var l = new List();
	var i = 0;
	var $it0 = it.iterator();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		l.add(f(i++,x));
	}
	$s.pop();
	return l;
	$s.pop();
}
Lambda.has = function(it,elt,cmp) {
	$s.push("Lambda::has");
	var $spos = $s.length;
	if(cmp == null) {
		var $it0 = it.iterator();
		while( $it0.hasNext() ) {
			var x = $it0.next();
			if(x == elt) {
				$s.pop();
				return true;
			}
		}
	} else {
		var $it1 = it.iterator();
		while( $it1.hasNext() ) {
			var x = $it1.next();
			if(cmp(x,elt)) {
				$s.pop();
				return true;
			}
		}
	}
	$s.pop();
	return false;
	$s.pop();
}
Lambda.exists = function(it,f) {
	$s.push("Lambda::exists");
	var $spos = $s.length;
	var $it0 = it.iterator();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		if(f(x)) {
			$s.pop();
			return true;
		}
	}
	$s.pop();
	return false;
	$s.pop();
}
Lambda.foreach = function(it,f) {
	$s.push("Lambda::foreach");
	var $spos = $s.length;
	var $it0 = it.iterator();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		if(!f(x)) {
			$s.pop();
			return false;
		}
	}
	$s.pop();
	return true;
	$s.pop();
}
Lambda.iter = function(it,f) {
	$s.push("Lambda::iter");
	var $spos = $s.length;
	var $it0 = it.iterator();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		f(x);
	}
	$s.pop();
}
Lambda.filter = function(it,f) {
	$s.push("Lambda::filter");
	var $spos = $s.length;
	var l = new List();
	var $it0 = it.iterator();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		if(f(x)) l.add(x);
	}
	$s.pop();
	return l;
	$s.pop();
}
Lambda.fold = function(it,f,first) {
	$s.push("Lambda::fold");
	var $spos = $s.length;
	var $it0 = it.iterator();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		first = f(x,first);
	}
	$s.pop();
	return first;
	$s.pop();
}
Lambda.count = function(it,pred) {
	$s.push("Lambda::count");
	var $spos = $s.length;
	var n = 0;
	if(pred == null) {
		var $it0 = it.iterator();
		while( $it0.hasNext() ) {
			var _ = $it0.next();
			n++;
		}
	} else {
		var $it1 = it.iterator();
		while( $it1.hasNext() ) {
			var x = $it1.next();
			if(pred(x)) n++;
		}
	}
	$s.pop();
	return n;
	$s.pop();
}
Lambda.empty = function(it) {
	$s.push("Lambda::empty");
	var $spos = $s.length;
	var $tmp = !it.iterator().hasNext();
	$s.pop();
	return $tmp;
	$s.pop();
}
Lambda.indexOf = function(it,v) {
	$s.push("Lambda::indexOf");
	var $spos = $s.length;
	var i = 0;
	var $it0 = it.iterator();
	while( $it0.hasNext() ) {
		var v2 = $it0.next();
		if(v == v2) {
			$s.pop();
			return i;
		}
		i++;
	}
	$s.pop();
	return -1;
	$s.pop();
}
Lambda.concat = function(a,b) {
	$s.push("Lambda::concat");
	var $spos = $s.length;
	var l = new List();
	var $it0 = a.iterator();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		l.add(x);
	}
	var $it1 = b.iterator();
	while( $it1.hasNext() ) {
		var x = $it1.next();
		l.add(x);
	}
	$s.pop();
	return l;
	$s.pop();
}
Lambda.prototype.__class__ = Lambda;
List = function(p) {
	if( p === $_ ) return;
	$s.push("List::new");
	var $spos = $s.length;
	this.length = 0;
	$s.pop();
}
List.__name__ = ["List"];
List.prototype.h = null;
List.prototype.q = null;
List.prototype.length = null;
List.prototype.add = function(item) {
	$s.push("List::add");
	var $spos = $s.length;
	var x = [item];
	if(this.h == null) this.h = x; else this.q[1] = x;
	this.q = x;
	this.length++;
	$s.pop();
}
List.prototype.push = function(item) {
	$s.push("List::push");
	var $spos = $s.length;
	var x = [item,this.h];
	this.h = x;
	if(this.q == null) this.q = x;
	this.length++;
	$s.pop();
}
List.prototype.first = function() {
	$s.push("List::first");
	var $spos = $s.length;
	var $tmp = this.h == null?null:this.h[0];
	$s.pop();
	return $tmp;
	$s.pop();
}
List.prototype.last = function() {
	$s.push("List::last");
	var $spos = $s.length;
	var $tmp = this.q == null?null:this.q[0];
	$s.pop();
	return $tmp;
	$s.pop();
}
List.prototype.pop = function() {
	$s.push("List::pop");
	var $spos = $s.length;
	if(this.h == null) {
		$s.pop();
		return null;
	}
	var x = this.h[0];
	this.h = this.h[1];
	if(this.h == null) this.q = null;
	this.length--;
	$s.pop();
	return x;
	$s.pop();
}
List.prototype.isEmpty = function() {
	$s.push("List::isEmpty");
	var $spos = $s.length;
	var $tmp = this.h == null;
	$s.pop();
	return $tmp;
	$s.pop();
}
List.prototype.clear = function() {
	$s.push("List::clear");
	var $spos = $s.length;
	this.h = null;
	this.q = null;
	this.length = 0;
	$s.pop();
}
List.prototype.remove = function(v) {
	$s.push("List::remove");
	var $spos = $s.length;
	var prev = null;
	var l = this.h;
	while(l != null) {
		if(l[0] == v) {
			if(prev == null) this.h = l[1]; else prev[1] = l[1];
			if(this.q == l) this.q = prev;
			this.length--;
			$s.pop();
			return true;
		}
		prev = l;
		l = l[1];
	}
	$s.pop();
	return false;
	$s.pop();
}
List.prototype.iterator = function() {
	$s.push("List::iterator");
	var $spos = $s.length;
	var $tmp = { h : this.h, hasNext : function() {
		$s.push("List::iterator@155");
		var $spos = $s.length;
		var $tmp = this.h != null;
		$s.pop();
		return $tmp;
		$s.pop();
	}, next : function() {
		$s.push("List::iterator@158");
		var $spos = $s.length;
		if(this.h == null) {
			$s.pop();
			return null;
		}
		var x = this.h[0];
		this.h = this.h[1];
		$s.pop();
		return x;
		$s.pop();
	}};
	$s.pop();
	return $tmp;
	$s.pop();
}
List.prototype.toString = function() {
	$s.push("List::toString");
	var $spos = $s.length;
	var s = new StringBuf();
	var first = true;
	var l = this.h;
	s.b[s.b.length] = "{";
	while(l != null) {
		if(first) first = false; else s.b[s.b.length] = ", ";
		s.b[s.b.length] = Std.string(l[0]);
		l = l[1];
	}
	s.b[s.b.length] = "}";
	var $tmp = s.b.join("");
	$s.pop();
	return $tmp;
	$s.pop();
}
List.prototype.join = function(sep) {
	$s.push("List::join");
	var $spos = $s.length;
	var s = new StringBuf();
	var first = true;
	var l = this.h;
	while(l != null) {
		if(first) first = false; else s.b[s.b.length] = sep;
		s.b[s.b.length] = l[0];
		l = l[1];
	}
	var $tmp = s.b.join("");
	$s.pop();
	return $tmp;
	$s.pop();
}
List.prototype.filter = function(f) {
	$s.push("List::filter");
	var $spos = $s.length;
	var l2 = new List();
	var l = this.h;
	while(l != null) {
		var v = l[0];
		l = l[1];
		if(f(v)) l2.add(v);
	}
	$s.pop();
	return l2;
	$s.pop();
}
List.prototype.map = function(f) {
	$s.push("List::map");
	var $spos = $s.length;
	var b = new List();
	var l = this.h;
	while(l != null) {
		var v = l[0];
		l = l[1];
		b.add(f(v));
	}
	$s.pop();
	return b;
	$s.pop();
}
List.prototype.__class__ = List;
ValueType = { __ename__ : ["ValueType"], __constructs__ : ["TNull","TInt","TFloat","TBool","TObject","TFunction","TClass","TEnum","TUnknown"] }
ValueType.TNull = ["TNull",0];
ValueType.TNull.toString = $estr;
ValueType.TNull.__enum__ = ValueType;
ValueType.TInt = ["TInt",1];
ValueType.TInt.toString = $estr;
ValueType.TInt.__enum__ = ValueType;
ValueType.TFloat = ["TFloat",2];
ValueType.TFloat.toString = $estr;
ValueType.TFloat.__enum__ = ValueType;
ValueType.TBool = ["TBool",3];
ValueType.TBool.toString = $estr;
ValueType.TBool.__enum__ = ValueType;
ValueType.TObject = ["TObject",4];
ValueType.TObject.toString = $estr;
ValueType.TObject.__enum__ = ValueType;
ValueType.TFunction = ["TFunction",5];
ValueType.TFunction.toString = $estr;
ValueType.TFunction.__enum__ = ValueType;
ValueType.TClass = function(c) { var $x = ["TClass",6,c]; $x.__enum__ = ValueType; $x.toString = $estr; return $x; }
ValueType.TEnum = function(e) { var $x = ["TEnum",7,e]; $x.__enum__ = ValueType; $x.toString = $estr; return $x; }
ValueType.TUnknown = ["TUnknown",8];
ValueType.TUnknown.toString = $estr;
ValueType.TUnknown.__enum__ = ValueType;
Type = function() { }
Type.__name__ = ["Type"];
Type.getClass = function(o) {
	$s.push("Type::getClass");
	var $spos = $s.length;
	if(o == null) {
		$s.pop();
		return null;
	}
	if(o.__enum__ != null) {
		$s.pop();
		return null;
	}
	var $tmp = o.__class__;
	$s.pop();
	return $tmp;
	$s.pop();
}
Type.getEnum = function(o) {
	$s.push("Type::getEnum");
	var $spos = $s.length;
	if(o == null) {
		$s.pop();
		return null;
	}
	var $tmp = o.__enum__;
	$s.pop();
	return $tmp;
	$s.pop();
}
Type.getSuperClass = function(c) {
	$s.push("Type::getSuperClass");
	var $spos = $s.length;
	var $tmp = c.__super__;
	$s.pop();
	return $tmp;
	$s.pop();
}
Type.getClassName = function(c) {
	$s.push("Type::getClassName");
	var $spos = $s.length;
	var a = c.__name__;
	var $tmp = a.join(".");
	$s.pop();
	return $tmp;
	$s.pop();
}
Type.getEnumName = function(e) {
	$s.push("Type::getEnumName");
	var $spos = $s.length;
	var a = e.__ename__;
	var $tmp = a.join(".");
	$s.pop();
	return $tmp;
	$s.pop();
}
Type.resolveClass = function(name) {
	$s.push("Type::resolveClass");
	var $spos = $s.length;
	var cl;
	try {
		cl = eval(name);
	} catch( e ) {
		$e = [];
		while($s.length >= $spos) $e.unshift($s.pop());
		$s.push($e[0]);
		cl = null;
	}
	if(cl == null || cl.__name__ == null) {
		$s.pop();
		return null;
	}
	$s.pop();
	return cl;
	$s.pop();
}
Type.resolveEnum = function(name) {
	$s.push("Type::resolveEnum");
	var $spos = $s.length;
	var e;
	try {
		e = eval(name);
	} catch( err ) {
		$e = [];
		while($s.length >= $spos) $e.unshift($s.pop());
		$s.push($e[0]);
		e = null;
	}
	if(e == null || e.__ename__ == null) {
		$s.pop();
		return null;
	}
	$s.pop();
	return e;
	$s.pop();
}
Type.createInstance = function(cl,args) {
	$s.push("Type::createInstance");
	var $spos = $s.length;
	if(args.length <= 3) {
		var $tmp = new cl(args[0],args[1],args[2]);
		$s.pop();
		return $tmp;
	}
	if(args.length > 8) throw "Too many arguments";
	var $tmp = new cl(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7]);
	$s.pop();
	return $tmp;
	$s.pop();
}
Type.createEmptyInstance = function(cl) {
	$s.push("Type::createEmptyInstance");
	var $spos = $s.length;
	var $tmp = new cl($_);
	$s.pop();
	return $tmp;
	$s.pop();
}
Type.createEnum = function(e,constr,params) {
	$s.push("Type::createEnum");
	var $spos = $s.length;
	var f = Reflect.field(e,constr);
	if(f == null) throw "No such constructor " + constr;
	if(Reflect.isFunction(f)) {
		if(params == null) throw "Constructor " + constr + " need parameters";
		var $tmp = f.apply(e,params);
		$s.pop();
		return $tmp;
	}
	if(params != null && params.length != 0) throw "Constructor " + constr + " does not need parameters";
	$s.pop();
	return f;
	$s.pop();
}
Type.createEnumIndex = function(e,index,params) {
	$s.push("Type::createEnumIndex");
	var $spos = $s.length;
	var c = e.__constructs__[index];
	if(c == null) throw index + " is not a valid enum constructor index";
	var $tmp = Type.createEnum(e,c,params);
	$s.pop();
	return $tmp;
	$s.pop();
}
Type.getInstanceFields = function(c) {
	$s.push("Type::getInstanceFields");
	var $spos = $s.length;
	var a = Reflect.fields(c.prototype);
	a.remove("__class__");
	$s.pop();
	return a;
	$s.pop();
}
Type.getClassFields = function(c) {
	$s.push("Type::getClassFields");
	var $spos = $s.length;
	var a = Reflect.fields(c);
	a.remove("__name__");
	a.remove("__interfaces__");
	a.remove("__super__");
	a.remove("prototype");
	$s.pop();
	return a;
	$s.pop();
}
Type.getEnumConstructs = function(e) {
	$s.push("Type::getEnumConstructs");
	var $spos = $s.length;
	var a = e.__constructs__;
	var $tmp = a.copy();
	$s.pop();
	return $tmp;
	$s.pop();
}
Type["typeof"] = function(v) {
	$s.push("Type::typeof");
	var $spos = $s.length;
	switch(typeof(v)) {
	case "boolean":
		var $tmp = ValueType.TBool;
		$s.pop();
		return $tmp;
	case "string":
		var $tmp = ValueType.TClass(String);
		$s.pop();
		return $tmp;
	case "number":
		if(Math.ceil(v) == v % 2147483648.0) {
			var $tmp = ValueType.TInt;
			$s.pop();
			return $tmp;
		}
		var $tmp = ValueType.TFloat;
		$s.pop();
		return $tmp;
	case "object":
		if(v == null) {
			var $tmp = ValueType.TNull;
			$s.pop();
			return $tmp;
		}
		var e = v.__enum__;
		if(e != null) {
			var $tmp = ValueType.TEnum(e);
			$s.pop();
			return $tmp;
		}
		var c = v.__class__;
		if(c != null) {
			var $tmp = ValueType.TClass(c);
			$s.pop();
			return $tmp;
		}
		var $tmp = ValueType.TObject;
		$s.pop();
		return $tmp;
	case "function":
		if(v.__name__ != null) {
			var $tmp = ValueType.TObject;
			$s.pop();
			return $tmp;
		}
		var $tmp = ValueType.TFunction;
		$s.pop();
		return $tmp;
	case "undefined":
		var $tmp = ValueType.TNull;
		$s.pop();
		return $tmp;
	default:
		var $tmp = ValueType.TUnknown;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Type.enumEq = function(a,b) {
	$s.push("Type::enumEq");
	var $spos = $s.length;
	if(a == b) {
		$s.pop();
		return true;
	}
	try {
		if(a[0] != b[0]) {
			$s.pop();
			return false;
		}
		var _g1 = 2, _g = a.length;
		while(_g1 < _g) {
			var i = _g1++;
			if(!Type.enumEq(a[i],b[i])) {
				$s.pop();
				return false;
			}
		}
		var e = a.__enum__;
		if(e != b.__enum__ || e == null) {
			$s.pop();
			return false;
		}
	} catch( e ) {
		$e = [];
		while($s.length >= $spos) $e.unshift($s.pop());
		$s.push($e[0]);
		$s.pop();
		return false;
	}
	$s.pop();
	return true;
	$s.pop();
}
Type.enumConstructor = function(e) {
	$s.push("Type::enumConstructor");
	var $spos = $s.length;
	var $tmp = e[0];
	$s.pop();
	return $tmp;
	$s.pop();
}
Type.enumParameters = function(e) {
	$s.push("Type::enumParameters");
	var $spos = $s.length;
	var $tmp = e.slice(2);
	$s.pop();
	return $tmp;
	$s.pop();
}
Type.enumIndex = function(e) {
	$s.push("Type::enumIndex");
	var $spos = $s.length;
	var $tmp = e[1];
	$s.pop();
	return $tmp;
	$s.pop();
}
Type.prototype.__class__ = Type;
if(typeof js=='undefined') js = {}
js.Lib = function() { }
js.Lib.__name__ = ["js","Lib"];
js.Lib.isIE = null;
js.Lib.isOpera = null;
js.Lib.document = null;
js.Lib.window = null;
js.Lib.alert = function(v) {
	$s.push("js.Lib::alert");
	var $spos = $s.length;
	alert(js.Boot.__string_rec(v,""));
	$s.pop();
}
js.Lib.eval = function(code) {
	$s.push("js.Lib::eval");
	var $spos = $s.length;
	var $tmp = eval(code);
	$s.pop();
	return $tmp;
	$s.pop();
}
js.Lib.setErrorHandler = function(f) {
	$s.push("js.Lib::setErrorHandler");
	var $spos = $s.length;
	js.Lib.onerror = f;
	$s.pop();
}
js.Lib.prototype.__class__ = js.Lib;
js.Boot = function() { }
js.Boot.__name__ = ["js","Boot"];
js.Boot.__unhtml = function(s) {
	$s.push("js.Boot::__unhtml");
	var $spos = $s.length;
	var $tmp = s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
	$s.pop();
	return $tmp;
	$s.pop();
}
js.Boot.__trace = function(v,i) {
	$s.push("js.Boot::__trace");
	var $spos = $s.length;
	var msg = i != null?i.fileName + ":" + i.lineNumber + ": ":"";
	msg += js.Boot.__unhtml(js.Boot.__string_rec(v,"")) + "<br/>";
	var d = document.getElementById("haxe:trace");
	if(d == null) alert("No haxe:trace element defined\n" + msg); else d.innerHTML += msg;
	$s.pop();
}
js.Boot.__clear_trace = function() {
	$s.push("js.Boot::__clear_trace");
	var $spos = $s.length;
	var d = document.getElementById("haxe:trace");
	if(d != null) d.innerHTML = "";
	$s.pop();
}
js.Boot.__closure = function(o,f) {
	$s.push("js.Boot::__closure");
	var $spos = $s.length;
	var m = o[f];
	if(m == null) {
		$s.pop();
		return null;
	}
	var f1 = function() {
		$s.push("js.Boot::__closure@67");
		var $spos = $s.length;
		var $tmp = m.apply(o,arguments);
		$s.pop();
		return $tmp;
		$s.pop();
	};
	f1.scope = o;
	f1.method = m;
	$s.pop();
	return f1;
	$s.pop();
}
js.Boot.__string_rec = function(o,s) {
	$s.push("js.Boot::__string_rec");
	var $spos = $s.length;
	if(o == null) {
		$s.pop();
		return "null";
	}
	if(s.length >= 5) {
		$s.pop();
		return "<...>";
	}
	var t = typeof(o);
	if(t == "function" && (o.__name__ != null || o.__ename__ != null)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__ != null) {
				if(o.length == 2) {
					var $tmp = o[0];
					$s.pop();
					return $tmp;
				}
				var str = o[0] + "(";
				s += "\t";
				var _g1 = 2, _g = o.length;
				while(_g1 < _g) {
					var i = _g1++;
					if(i != 2) str += "," + js.Boot.__string_rec(o[i],s); else str += js.Boot.__string_rec(o[i],s);
				}
				var $tmp = str + ")";
				$s.pop();
				return $tmp;
			}
			var l = o.length;
			var i;
			var str = "[";
			s += "\t";
			var _g = 0;
			while(_g < l) {
				var i1 = _g++;
				str += (i1 > 0?",":"") + js.Boot.__string_rec(o[i1],s);
			}
			str += "]";
			$s.pop();
			return str;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			$e = [];
			while($s.length >= $spos) $e.unshift($s.pop());
			$s.push($e[0]);
			$s.pop();
			return "???";
		}
		if(tostr != null && tostr != Object.toString) {
			var s2 = o.toString();
			if(s2 != "[object Object]") {
				$s.pop();
				return s2;
			}
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) { ;
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__") {
			continue;
		}
		if(str.length != 2) str += ", \n";
		str += s + k + " : " + js.Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		$s.pop();
		return str;
	case "function":
		$s.pop();
		return "<function>";
	case "string":
		$s.pop();
		return o;
	default:
		var $tmp = String(o);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
js.Boot.__interfLoop = function(cc,cl) {
	$s.push("js.Boot::__interfLoop");
	var $spos = $s.length;
	if(cc == null) {
		$s.pop();
		return false;
	}
	if(cc == cl) {
		$s.pop();
		return true;
	}
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0, _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js.Boot.__interfLoop(i1,cl)) {
				$s.pop();
				return true;
			}
		}
	}
	var $tmp = js.Boot.__interfLoop(cc.__super__,cl);
	$s.pop();
	return $tmp;
	$s.pop();
}
js.Boot.__instanceof = function(o,cl) {
	$s.push("js.Boot::__instanceof");
	var $spos = $s.length;
	try {
		if(o instanceof cl) {
			if(cl == Array) {
				var $tmp = o.__enum__ == null;
				$s.pop();
				return $tmp;
			}
			$s.pop();
			return true;
		}
		if(js.Boot.__interfLoop(o.__class__,cl)) {
			$s.pop();
			return true;
		}
	} catch( e ) {
		$e = [];
		while($s.length >= $spos) $e.unshift($s.pop());
		$s.push($e[0]);
		if(cl == null) {
			$s.pop();
			return false;
		}
	}
	switch(cl) {
	case Int:
		var $tmp = Math.ceil(o%2147483648.0) === o;
		$s.pop();
		return $tmp;
	case Float:
		var $tmp = typeof(o) == "number";
		$s.pop();
		return $tmp;
	case Bool:
		var $tmp = o === true || o === false;
		$s.pop();
		return $tmp;
	case String:
		var $tmp = typeof(o) == "string";
		$s.pop();
		return $tmp;
	case Dynamic:
		$s.pop();
		return true;
	default:
		if(o == null) {
			$s.pop();
			return false;
		}
		var $tmp = o.__enum__ == cl || cl == Class && o.__name__ != null || cl == Enum && o.__ename__ != null;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
js.Boot.__init = function() {
	$s.push("js.Boot::__init");
	var $spos = $s.length;
	js.Lib.isIE = typeof document!='undefined' && document.all != null && typeof window!='undefined' && window.opera == null;
	js.Lib.isOpera = typeof window!='undefined' && window.opera != null;
	Array.prototype.copy = Array.prototype.slice;
	Array.prototype.insert = function(i,x) {
		$s.push("js.Boot::__init@205");
		var $spos = $s.length;
		this.splice(i,0,x);
		$s.pop();
	};
	Array.prototype.remove = Array.prototype.indexOf?function(obj) {
		$s.push("js.Boot::__init@208");
		var $spos = $s.length;
		var idx = this.indexOf(obj);
		if(idx == -1) {
			$s.pop();
			return false;
		}
		this.splice(idx,1);
		$s.pop();
		return true;
		$s.pop();
	}:function(obj) {
		$s.push("js.Boot::__init@213");
		var $spos = $s.length;
		var i = 0;
		var l = this.length;
		while(i < l) {
			if(this[i] == obj) {
				this.splice(i,1);
				$s.pop();
				return true;
			}
			i++;
		}
		$s.pop();
		return false;
		$s.pop();
	};
	Array.prototype.iterator = function() {
		$s.push("js.Boot::__init@225");
		var $spos = $s.length;
		var $tmp = { cur : 0, arr : this, hasNext : function() {
			$s.push("js.Boot::__init@225@229");
			var $spos = $s.length;
			var $tmp = this.cur < this.arr.length;
			$s.pop();
			return $tmp;
			$s.pop();
		}, next : function() {
			$s.push("js.Boot::__init@225@232");
			var $spos = $s.length;
			var $tmp = this.arr[this.cur++];
			$s.pop();
			return $tmp;
			$s.pop();
		}};
		$s.pop();
		return $tmp;
		$s.pop();
	};
	if(String.prototype.cca == null) String.prototype.cca = String.prototype.charCodeAt;
	String.prototype.charCodeAt = function(i) {
		$s.push("js.Boot::__init@239");
		var $spos = $s.length;
		var x = this.cca(i);
		if(x != x) {
			$s.pop();
			return null;
		}
		$s.pop();
		return x;
		$s.pop();
	};
	var oldsub = String.prototype.substr;
	String.prototype.substr = function(pos,len) {
		$s.push("js.Boot::__init@246");
		var $spos = $s.length;
		if(pos != null && pos != 0 && len != null && len < 0) {
			$s.pop();
			return "";
		}
		if(len == null) len = this.length;
		if(pos < 0) {
			pos = this.length + pos;
			if(pos < 0) pos = 0;
		} else if(len < 0) len = this.length + len - pos;
		var $tmp = oldsub.apply(this,[pos,len]);
		$s.pop();
		return $tmp;
		$s.pop();
	};
	
				[].indexOf || (Array.prototype.indexOf = function(v,n)
				{
				  n = (n == null) ? 0 : n;
				  var m = this.length;
				  for(var i = n; i < m; i++)
					if(this[i] == v)
					   return i;
				  return -1;
				});
			;
	String.prototype.replaceAll = function(what,by) {
		$s.push("js.Boot::__init@270");
		var $spos = $s.length;
		var $tmp = this.split(what).join(by);
		$s.pop();
		return $tmp;
		$s.pop();
	};
	String.prototype.ltrim = function(charList) {
		$s.push("js.Boot::__init@273");
		var $spos = $s.length;
		if(charList == null) charList = " \t\r\n";
		var $tmp = this.replace(new RegExp('^[' + charList + ']+', 'g'), '');
		$s.pop();
		return $tmp;
		$s.pop();
	};
	String.prototype.rtrim = function(charList) {
		$s.push("js.Boot::__init@277");
		var $spos = $s.length;
		if(charList == null) charList = " \t\r\n";
		var $tmp = this.replace(new RegExp('[' + charList + ']+$', 'g'), '');
		$s.pop();
		return $tmp;
		$s.pop();
	};
	String.prototype.trim = function(charList) {
		$s.push("js.Boot::__init@281");
		var $spos = $s.length;
		var $tmp = this.ltrim(charList).rtrim(charList);
		$s.pop();
		return $tmp;
		$s.pop();
	};
	$closure = js.Boot.__closure;
	$s.pop();
}
js.Boot.prototype.__class__ = js.Boot;
haquery.client.HaqTemplates = function(componentsFolders,serverHandlers) {
	if( componentsFolders === $_ ) return;
	$s.push("haquery.client.HaqTemplates::new");
	var $spos = $s.length;
	this.componentsFolders = componentsFolders;
	this.tag_elemID_serverHandlers = new Hash();
	var _g = 0;
	while(_g < serverHandlers.length) {
		var sh = serverHandlers[_g];
		++_g;
		var tag = sh[0];
		var _g2 = 1, _g1 = sh.length;
		while(_g2 < _g1) {
			var i = _g2++;
			var elemID_eventNames = sh[i];
			var elemID = elemID_eventNames[0];
			var eventNames = elemID_eventNames[1];
			if(!this.tag_elemID_serverHandlers.exists(tag)) this.tag_elemID_serverHandlers.set(tag,new Hash());
			this.tag_elemID_serverHandlers.get(tag).set(elemID,eventNames.split(","));
		}
	}
	$s.pop();
}
haquery.client.HaqTemplates.__name__ = ["haquery","client","HaqTemplates"];
haquery.client.HaqTemplates.prototype.componentsFolders = null;
haquery.client.HaqTemplates.prototype.tag_elemID_serverHandlers = null;
haquery.client.HaqTemplates.prototype.get = function(tag) {
	$s.push("haquery.client.HaqTemplates::get");
	var $spos = $s.length;
	var r = { elemID_serverHandlers : this.tag_elemID_serverHandlers.get(tag), clas : null};
	var i = this.componentsFolders.length - 1;
	while(i >= 0) {
		var folder = this.componentsFolders[i];
		var className = folder.replaceAll("/",".") + tag + ".Client";
		var clas = Type.resolveClass(className);
		if(clas != null) {
			r.clas = clas;
			break;
		}
		i--;
	}
	if(r.clas == null) r.clas = Type.resolveClass("haquery.client.HaqComponent");
	$s.pop();
	return r;
	$s.pop();
}
haquery.client.HaqTemplates.prototype.__class__ = haquery.client.HaqTemplates;
haquery.base.HaqEvent = function(component,name) {
	if( component === $_ ) return;
	$s.push("haquery.base.HaqEvent::new");
	var $spos = $s.length;
	this.handlers = new Array();
	this.component = component;
	this.name = name;
	$s.pop();
}
haquery.base.HaqEvent.__name__ = ["haquery","base","HaqEvent"];
haquery.base.HaqEvent.prototype.handlers = null;
haquery.base.HaqEvent.prototype.component = null;
haquery.base.HaqEvent.prototype.name = null;
haquery.base.HaqEvent.prototype.bind = function(obj,func) {
	$s.push("haquery.base.HaqEvent::bind");
	var $spos = $s.length;
	this.handlers.push({ o : obj, f : func});
	$s.pop();
	return this;
	$s.pop();
}
haquery.base.HaqEvent.prototype.call = function(params) {
	$s.push("haquery.base.HaqEvent::call");
	var $spos = $s.length;
	var i = this.handlers.length - 1;
	while(i >= 0) {
		var obj = this.handlers[i].o;
		var func = this.handlers[i].f;
		var r = func.apply(obj,params);
		if(r === false) {
			$s.pop();
			return false;
		}
		i--;
	}
	$s.pop();
	return true;
	$s.pop();
}
haquery.base.HaqEvent.prototype.__class__ = haquery.base.HaqEvent;
EReg = function(r,opt) {
	if( r === $_ ) return;
	$s.push("EReg::new");
	var $spos = $s.length;
	opt = opt.split("u").join("");
	this.r = new RegExp(r,opt);
	$s.pop();
}
EReg.__name__ = ["EReg"];
EReg.prototype.r = null;
EReg.prototype.match = function(s) {
	$s.push("EReg::match");
	var $spos = $s.length;
	this.r.m = this.r.exec(s);
	this.r.s = s;
	this.r.l = RegExp.leftContext;
	this.r.r = RegExp.rightContext;
	var $tmp = this.r.m != null;
	$s.pop();
	return $tmp;
	$s.pop();
}
EReg.prototype.matched = function(n) {
	$s.push("EReg::matched");
	var $spos = $s.length;
	var $tmp = this.r.m != null && n >= 0 && n < this.r.m.length?this.r.m[n]:(function($this) {
		var $r;
		throw "EReg::matched";
		return $r;
	}(this));
	$s.pop();
	return $tmp;
	$s.pop();
}
EReg.prototype.matchedLeft = function() {
	$s.push("EReg::matchedLeft");
	var $spos = $s.length;
	if(this.r.m == null) throw "No string matched";
	if(this.r.l == null) {
		var $tmp = this.r.s.substr(0,this.r.m.index);
		$s.pop();
		return $tmp;
	}
	var $tmp = this.r.l;
	$s.pop();
	return $tmp;
	$s.pop();
}
EReg.prototype.matchedRight = function() {
	$s.push("EReg::matchedRight");
	var $spos = $s.length;
	if(this.r.m == null) throw "No string matched";
	if(this.r.r == null) {
		var sz = this.r.m.index + this.r.m[0].length;
		var $tmp = this.r.s.substr(sz,this.r.s.length - sz);
		$s.pop();
		return $tmp;
	}
	var $tmp = this.r.r;
	$s.pop();
	return $tmp;
	$s.pop();
}
EReg.prototype.matchedPos = function() {
	$s.push("EReg::matchedPos");
	var $spos = $s.length;
	if(this.r.m == null) throw "No string matched";
	var $tmp = { pos : this.r.m.index, len : this.r.m[0].length};
	$s.pop();
	return $tmp;
	$s.pop();
}
EReg.prototype.split = function(s) {
	$s.push("EReg::split");
	var $spos = $s.length;
	var d = "#__delim__#";
	var $tmp = s.replaceAll(this.r,d).split(d);
	$s.pop();
	return $tmp;
	$s.pop();
}
EReg.prototype.replace = function(s,by) {
	$s.push("EReg::replace");
	var $spos = $s.length;
	var $tmp = s.replaceAll(this.r,by);
	$s.pop();
	return $tmp;
	$s.pop();
}
EReg.prototype.customReplace = function(s,f) {
	$s.push("EReg::customReplace");
	var $spos = $s.length;
	var buf = new StringBuf();
	while(true) {
		if(!this.match(s)) break;
		buf.b[buf.b.length] = this.matchedLeft();
		buf.b[buf.b.length] = f(this);
		s = this.matchedRight();
	}
	buf.b[buf.b.length] = s;
	var $tmp = buf.b.join("");
	$s.pop();
	return $tmp;
	$s.pop();
}
EReg.prototype.__class__ = EReg;
haquery.client.HaqSystem = function(p) {
	if( p === $_ ) return;
	$s.push("haquery.client.HaqSystem::new");
	var $spos = $s.length;
	var templates = new haquery.client.HaqTemplates(haquery.client.HaqInternals.componentsFolders,haquery.client.HaqInternals.serverHandlers);
	var manager = new haquery.client.HaqComponentManager(templates,haquery.client.HaqInternals.id_tag_getter());
	var page = manager.createPage();
	var _g = 0, _g1 = new $("*[id]").toArray();
	while(_g < _g1.length) {
		var elem = _g1[_g];
		++_g;
		haquery.client.HaqSystem.connectElemEventHandlers(page,templates,elem);
	}
	$s.pop();
}
haquery.client.HaqSystem.__name__ = ["haquery","client","HaqSystem"];
haquery.client.HaqSystem.connectElemEventHandlers = function(page,templates,elem) {
	$s.push("haquery.client.HaqSystem::connectElemEventHandlers");
	var $spos = $s.length;
	var n = elem.getAttribute("id").lastIndexOf("-");
	var componentID = n > 0?elem.getAttribute("id").substr(0,n):"";
	var elemID = n > 0?elem.getAttribute("id").substr(n + 1):elem.getAttribute("id");
	var component = page.findComponent(componentID);
	if(component == null) {
		$s.pop();
		return;
	}
	var _g = 0, _g1 = haquery.client.HaqSystem.elemEventNames;
	while(_g < _g1.length) {
		var eventName = _g1[_g];
		++_g;
		if(Reflect.hasMethod(component,elemID + "_" + eventName) || templates.get(component.tag).elemID_serverHandlers != null && templates.get(component.tag).elemID_serverHandlers.get(elemID) != null && templates.get(component.tag).elemID_serverHandlers.get(elemID).indexOf(eventName) != -1) new $(elem).bind(eventName,null,function(e) {
			$s.push("haquery.client.HaqSystem::connectElemEventHandlers@45");
			var $spos = $s.length;
			var $tmp = haquery.client.HaqSystem.elemEventHandler(templates,page,elem,e);
			$s.pop();
			return $tmp;
			$s.pop();
		});
	}
	$s.pop();
}
haquery.client.HaqSystem.elemEventHandler = function(templates,page,elem,e) {
	$s.push("haquery.client.HaqSystem::elemEventHandler");
	var $spos = $s.length;
	var n = elem.id.lastIndexOf("-");
	var componentID = n > 0?elem.getAttribute("id").substr(0,n):"";
	var component = page.findComponent(componentID);
	haquery.base.HaQuery.assert(component != null,null,{ fileName : "HaqSystem.hx", lineNumber : 55, className : "haquery.client.HaqSystem", methodName : "elemEventHandler"});
	var r = haquery.client.HaqSystem.callClientElemEventHandlers(component,elem,e);
	if(!r) {
		$s.pop();
		return false;
	}
	var $tmp = haquery.client.HaqSystem.callServerElemEventHandlers(templates,component,elem,e);
	$s.pop();
	return $tmp;
	$s.pop();
}
haquery.client.HaqSystem.callClientElemEventHandlers = function(component,elem,e) {
	$s.push("haquery.client.HaqSystem::callClientElemEventHandlers");
	var $spos = $s.length;
	var n = elem.id.lastIndexOf("-");
	var elemID = n > 0?elem.id.substr(n + 1):elem.id;
	var methodName = elemID + "_" + e.type;
	if(Reflect.hasMethod(component,methodName)) {
		var r = Reflect.field(component,methodName).apply(component,[e]);
		if(r == false) {
			$s.pop();
			return false;
		}
	}
	$s.pop();
	return true;
	$s.pop();
}
haquery.client.HaqSystem.callServerElemEventHandlers = function(templates,component,elem,e) {
	$s.push("haquery.client.HaqSystem::callServerElemEventHandlers");
	var $spos = $s.length;
	var n = elem.id.lastIndexOf("-");
	var elemID = n > 0?elem.id.substr(n + 1):elem.id;
	if(templates.get(component.tag).elemID_serverHandlers == null || templates.get(component.tag).elemID_serverHandlers.get(elemID) == null) {
		$s.pop();
		return true;
	}
	var handlers = templates.get(component.tag).elemID_serverHandlers.get(elemID);
	if(handlers.indexOf(e.type) == -1) {
		$s.pop();
		return true;
	}
	var sendData = { };
	sendData["HAQUERY_POSTBACK"] = 1;
	sendData["HAQUERY_ID"] = elem.id;
	sendData["HAQUERY_EVENT"] = e.type;
	var $it0 = haquery.client.HaqSystem.getElemsForSendToServer(component).iterator();
	while( $it0.hasNext() ) {
		var sendElem = $it0.next();
		sendData[sendElem.id] = sendElem.nodeName.toUpperCase() == "INPUT" && sendElem.getAttribute("type").toUpperCase() == "CHECKBOX"?Reflect.field(sendElem,"checked")?new $(sendElem).val():"":new $(sendElem).val();
	}
	$.post(js.Lib.window.location.href,sendData,function(data) {
		$s.push("haquery.client.HaqSystem::callServerElemEventHandlers@104");
		var $spos = $s.length;
		var okMsg = "HAQUERY_OK";
		if(StringTools.startsWith(data,okMsg)) {
			var code = data.substr(okMsg.length);
			haxe.Log.trace("AJAX: " + code,{ fileName : "HaqSystem.hx", lineNumber : 110, className : "haquery.client.HaqSystem", methodName : "callServerElemEventHandlers"});
			eval(code);
		} else {
			var errWin = js.Lib.window.open("","HAQUERY_ERROR_AJAX");
			errWin.document.write(data);
		}
		$s.pop();
	});
	$s.pop();
	return true;
	$s.pop();
}
haquery.client.HaqSystem.getElemsForSendToServer = function(component) {
	$s.push("haquery.client.HaqSystem::getElemsForSendToServer");
	var $spos = $s.length;
	var idParts = component.fullID.split("-");
	var reStr = "(^[^" + "-" + "]+$)";
	haxe.Log.trace("reStr = " + reStr,{ fileName : "HaqSystem.hx", lineNumber : 128, className : "haquery.client.HaqSystem", methodName : "getElemsForSendToServer"});
	var _g1 = 0, _g = idParts.length;
	while(_g1 < _g) {
		var i = _g1++;
		var s = "(^" + idParts.slice(0,i + 1).join("-") + "-" + "[^" + "-" + "]+$)";
		haxe.Log.trace("reStr = " + s,{ fileName : "HaqSystem.hx", lineNumber : 132, className : "haquery.client.HaqSystem", methodName : "getElemsForSendToServer"});
		reStr += "|" + s;
	}
	var re = new EReg(reStr,"");
	var jqAllElemsWithID = new $("[id]");
	var allElemsWithID = jqAllElemsWithID.toArray();
	var elems = Lambda.filter(allElemsWithID,function(elem) {
		$s.push("haquery.client.HaqSystem::getElemsForSendToServer@139");
		var $spos = $s.length;
		if(!re.match(elem.id)) {
			$s.pop();
			return false;
		}
		var elemTag = elem.nodeName.toUpperCase();
		var elemType = elemTag == "INPUT"?elem.getAttribute("type").toUpperCase():"";
		var $tmp = elemTag == "INPUT" && Lambda.has(["PASSWORD","HIDDEN","CHECKBOX","RADIO"],elemType) || elemTag == "TEXTAREA" || elemTag == "SELECT";
		$s.pop();
		return $tmp;
		$s.pop();
	});
	$s.pop();
	return elems;
	$s.pop();
}
haquery.client.HaqSystem.prototype.__class__ = haquery.client.HaqSystem;
Hash = function(p) {
	if( p === $_ ) return;
	$s.push("Hash::new");
	var $spos = $s.length;
	this.h = {}
	if(this.h.__proto__ != null) {
		this.h.__proto__ = null;
		delete(this.h.__proto__);
	}
	$s.pop();
}
Hash.__name__ = ["Hash"];
Hash.prototype.h = null;
Hash.prototype.set = function(key,value) {
	$s.push("Hash::set");
	var $spos = $s.length;
	this.h["$" + key] = value;
	$s.pop();
}
Hash.prototype.get = function(key) {
	$s.push("Hash::get");
	var $spos = $s.length;
	var $tmp = this.h["$" + key];
	$s.pop();
	return $tmp;
	$s.pop();
}
Hash.prototype.exists = function(key) {
	$s.push("Hash::exists");
	var $spos = $s.length;
	try {
		key = "$" + key;
		var $tmp = this.hasOwnProperty.call(this.h,key);
		$s.pop();
		return $tmp;
	} catch( e ) {
		$e = [];
		while($s.length >= $spos) $e.unshift($s.pop());
		$s.push($e[0]);
		for(var i in this.h) if( i == key ) return true;
		$s.pop();
		return false;
	}
	$s.pop();
}
Hash.prototype.remove = function(key) {
	$s.push("Hash::remove");
	var $spos = $s.length;
	if(!this.exists(key)) {
		$s.pop();
		return false;
	}
	delete(this.h["$" + key]);
	$s.pop();
	return true;
	$s.pop();
}
Hash.prototype.keys = function() {
	$s.push("Hash::keys");
	var $spos = $s.length;
	var a = new Array();
	for(var i in this.h) a.push(i.substr(1));
	var $tmp = a.iterator();
	$s.pop();
	return $tmp;
	$s.pop();
}
Hash.prototype.iterator = function() {
	$s.push("Hash::iterator");
	var $spos = $s.length;
	var $tmp = { ref : this.h, it : this.keys(), hasNext : function() {
		$s.push("Hash::iterator@75");
		var $spos = $s.length;
		var $tmp = this.it.hasNext();
		$s.pop();
		return $tmp;
		$s.pop();
	}, next : function() {
		$s.push("Hash::iterator@76");
		var $spos = $s.length;
		var i = this.it.next();
		var $tmp = this.ref["$" + i];
		$s.pop();
		return $tmp;
		$s.pop();
	}};
	$s.pop();
	return $tmp;
	$s.pop();
}
Hash.prototype.toString = function() {
	$s.push("Hash::toString");
	var $spos = $s.length;
	var s = new StringBuf();
	s.b[s.b.length] = "{";
	var it = this.keys();
	while( it.hasNext() ) {
		var i = it.next();
		s.b[s.b.length] = i;
		s.b[s.b.length] = " => ";
		s.b[s.b.length] = Std.string(this.get(i));
		if(it.hasNext()) s.b[s.b.length] = ", ";
	}
	s.b[s.b.length] = "}";
	var $tmp = s.b.join("");
	$s.pop();
	return $tmp;
	$s.pop();
}
Hash.prototype.__class__ = Hash;
Main = function() { }
Main.__name__ = ["Main"];
Main.main = function() {
	$s.push("Main::main");
	var $spos = $s.length;
	$s.pop();
}
Main.prototype.__class__ = Main;
$_ = {}
js.Boot.__res = {}
$s = [];
$e = [];
js.Boot.__init();
{
	String.prototype.__class__ = String;
	String.__name__ = ["String"];
	Array.prototype.__class__ = Array;
	Array.__name__ = ["Array"];
	Int = { __name__ : ["Int"]};
	Dynamic = { __name__ : ["Dynamic"]};
	Float = Number;
	Float.__name__ = ["Float"];
	Bool = { __ename__ : ["Bool"]};
	Class = { __name__ : ["Class"]};
	Enum = { };
	Void = { __ename__ : ["Void"]};
}
{
	Math.__name__ = ["Math"];
	Math.NaN = Number["NaN"];
	Math.NEGATIVE_INFINITY = Number["NEGATIVE_INFINITY"];
	Math.POSITIVE_INFINITY = Number["POSITIVE_INFINITY"];
	Math.isFinite = function(i) {
		$s.push("Main::main");
		var $spos = $s.length;
		var $tmp = isFinite(i);
		$s.pop();
		return $tmp;
		$s.pop();
	};
	Math.isNaN = function(i) {
		$s.push("Main::main");
		var $spos = $s.length;
		var $tmp = isNaN(i);
		$s.pop();
		return $tmp;
		$s.pop();
	};
}
{
	js.Lib.document = document;
	js.Lib.window = window;
	onerror = function(msg,url,line) {
		var stack = $s.copy();
		var f = js.Lib.onerror;
		$s.splice(0,$s.length);
		if( f == null ) {
			var i = stack.length;
			var s = "";
			while( --i >= 0 )
				s += "Called from "+stack[i]+"\n";
			alert(msg+"\n\n"+s);
			return false;
		}
		return f(msg,stack);
	}
}
js["XMLHttpRequest"] = window.XMLHttpRequest?XMLHttpRequest:window.ActiveXObject?function() {
	$s.push("Main::main");
	var $spos = $s.length;
	try {
		var $tmp = new ActiveXObject("Msxml2.XMLHTTP");
		$s.pop();
		return $tmp;
	} catch( e ) {
		$e = [];
		while($s.length >= $spos) $e.unshift($s.pop());
		$s.push($e[0]);
		try {
			var $tmp = new ActiveXObject("Microsoft.XMLHTTP");
			$s.pop();
			return $tmp;
		} catch( e1 ) {
			$e = [];
			while($s.length >= $spos) $e.unshift($s.pop());
			$s.push($e[0]);
			throw "Unable to create XMLHttpRequest object.";
		}
	}
	$s.pop();
}:(function($this) {
	var $r;
	throw "Unable to create XMLHttpRequest object.";
	return $r;
}(this));
haquery.base.HaQuery.VERSION = 2.1;
haquery.base.HaQuery.folders = { pages : "pages/", support : "support/", temp : "temp/"};
haquery.client.HaqInternals.DELIMITER = "-";
js.Lib.onerror = null;
haquery.client.HaqSystem.elemEventNames = ["click","change","load","mousedown","mouseup","mousemove","mouseover","mouseout","mouseenter","mouseleave","keypress","keydown","keyup","focus","focusin","focusout"];
Main.main()