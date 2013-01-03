package haquery.macro.internal.macro.build;
 
import haxe.macro.Expr;
import haquery.macro.internal.macro.tools.Printer;
import haquery.macro.internal.core.types.Outcome;

using Lambda;
using haquery.macro.internal.macro.tools.MacroTools;

typedef Meta = { 
	name : String,
	params : Array<Expr>, 
	pos : Position 
};

class Member {
	public var name : String;
	public var doc : Null<String>;
	public var kind : FieldType;
	public var pos : Position;
	var meta:Hash<Array<Meta>>;
	
	public var isOverride:Bool;
	public var isStatic:Bool;
	///indicates whether the field is inline (true) or dynamic (false) or none of both (null)
	public var isBound:Null<Bool>;
	public var isPublic:Null<Bool>;
	public var excluded:Bool;
	
	public function new() {
		this.isOverride = this.isStatic = false;
		this.meta = new Hash();
		this.excluded = false;
	}
	public inline function forceInline() {
		this.isBound = true;
		addMeta(':extern', pos);
	}
	public inline function publish() {
		if (isPublic == null) 
			isPublic = true;
	}
	public function addMeta(name, pos, ?params) {
		if (!meta.exists(name))
			meta.set(name, []);
		meta.get(name).push({
			name: name,
			pos: pos,
			params: if (params == null) [] else params
		});
	}
	public function disallowMeta(id:String, master:String) {
		if (meta.exists(id))
			meta.get(id)[0].pos.error('cannot use tag ' + id + ' if ' + master + ' is used');
	}
	public function extractMeta(name) {
		return
			if (meta.exists(name)) {
				var ret = meta.get(name);
				if (ret.length == 1)
					meta.remove(name);
				return Success(ret.shift());
			}
			else return Failure();
	}
	public function toString() {
		var ret = '';
		for (tags in meta)
			for (tag in tags)
				ret += '@' + tag.name + Printer.printExprList('', tag.params);
		if (isStatic) ret += 'static ';
		if (isPublic == true) ret += 'public ';
		else if (isPublic == false) ret += 'private ';
		switch (kind) {
			case FVar(t, e): 
				ret += 'var ' + name + ':' + Printer.printType('', t);
				if (e != null)
					ret += ' = ' + e.toString();
				ret += ';';
			case FProp(get, set, t, e):
				ret += 'var ' + name + '(' + get + ', ' + set + '):' + Printer.printType('', t);
				if (e != null)
					ret += ' = ' + e.toString();
				ret += ';';
			case FFun(f):
				ret += Printer.printFunction(f, name);
		}
		return ret;
	}
	public function toHaxe():Field {
		return {
			name : name,
			doc : doc,
			access : haxeAccess(),
			kind : kind,
			pos : pos,
			meta : {
				var res = [];
				for (tags in meta)
					for (tag in tags)
						res.push(tag);
				//meta.array(),			
				res;
			}
		}
	}
	public function getFunction() {
		return
			switch (kind) {
				case FFun(f): Success(f);
				default: pos.makeFailure('not a function');
			}
	}
	function haxeAccess():Array<Access> {
		var ret = [];
		switch (isPublic) {
			case true: ret.push(APublic);
			case false: ret.push(APrivate);
		}
		switch (isBound) {
			case true: ret.push(AInline);
			case false: ret.push(ADynamic);
		}
		if (isOverride) ret.push(AOverride);
		if (isStatic) ret.push(AStatic);
		return ret;
	}
	static public function prop(name:String, t:ComplexType, pos, ?noread = false, ?nowrite = false) {
		var ret = new Member();
		ret.name = name;
		ret.publish();
		ret.pos = pos;
		ret.kind = FProp(noread ? 'null' : 'get_' + name, nowrite ? 'null' : ('set_' + name), t);
		return ret;
	}
	static public function getter(field:String, ?pos, e:Expr, ?t:ComplexType) {
		return method('get_' + field, pos, false, e.func(t));
	}
	static public function setter(field:String, ?param = 'param', ?pos, e:Expr, ?t:ComplexType) {
		return method('set_' + field, pos, false, [e, param.resolve(pos)].toBlock(pos).func([param.toArg(t)], t));
	}
	static public function method(name:String, ?pos, ?isPublic = true, f:Function) {
		var ret = new Member();
		ret.name = name;
		ret.kind = FFun(f);
		ret.pos = if (pos == null) f.expr.pos else pos;
		ret.isPublic = isPublic;
		return ret;
	}
	static public function ofHaxe(f:Field) {
		var ret = new Member();
		
		ret.name = f.name;
		ret.doc = f.doc;
		ret.pos = f.pos;
		ret.kind = f.kind;
		
		for (m in f.meta) 
			ret.addMeta(m.name, m.pos, m.params);
		
		for (a in f.access) 
			switch (a) {
				case APublic: ret.isPublic = true;
				case APrivate: ret.isPublic = false;
				
				case AStatic: ret.isStatic = true;
				
				case AOverride: ret.isOverride = true;
				
				case ADynamic: ret.isBound = false;
				case AInline: ret.isBound = true;
			}
			
		return ret;
	}
	
	static public function plain(name:String, type:ComplexType, pos:Position) {
		return ofHaxe( {
			name: name, 
			doc: null,
			access: [],
			kind: FVar(type),
			pos: pos,
			meta: []
		});
	}
}