package haquery.macros.internal.macro.build;

private typedef Enums = Type;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import haquery.macros.internal.macro.tools.Printer;

using haquery.macros.internal.macro.tools.MacroTools;
using haquery.macros.internal.core.types.Outcome;

/**
 * ...
 * @author back2dos
 */

typedef ClassBuildContext = {
	cls:ClassType,
	members:Array<Member>,
	getCtor:Void->Constructor,
	has:String->Bool,
	get:String->Member,
	hasOwn:String->Bool,
	add:Member->Member
}
class MemberTransformer {
	
	var members:Hash<Member>;
	var constructor:Null<Constructor>;
	var localClass:ClassType;
	var superFields:Hash<Bool>;
	var verbose:Bool;
	public function new(?verbose) { 
		members = new Hash();
		localClass = Context.getLocalClass().get();
		this.verbose = verbose;
	}
	function getConstructor() {
		if (constructor == null) 
			if (localClass.superClass != null && localClass.superClass.t.get().constructor != null) {
				var ctor = Context.getLocalClass().get().superClass.t.get().constructor.get();
				var func = Context.getTypedExpr(ctor.expr()).getFunction().sure();
				func.expr = "super".resolve().call(func.getArgIdents());
				constructor = new Constructor(localClass.isInterface, func);
				if (ctor.isPublic)
					constructor.publish();
			}
			else
				constructor = new Constructor(localClass.isInterface, null);
		return constructor;
	}
	function prune(a:Array<Member>) {
		var ret = [];
		for (m in a) 
			if (!m.excluded) {
				if (localClass.isInterface)
					switch (m.kind) {
						case FFun(f): f.expr = null;
						default:
					}
				ret.push(m);
			}
		return ret;
	}
	public function build(plugins:Iterable<ClassBuildContext->Void>) {
		var fields = [];
		for (field in Context.getBuildFields()) 
			addMember(fields, Member.ofHaxe(field));
			
		var context = {
			cls: localClass,
			members: fields,
			getCtor: getConstructor,
			has: hasMember,
			get: getOwnMember,
			hasOwn: hasOwnMember,
			add: null
		}
		
		for (plugin in plugins) {
			context.add = callback(addMember, context.members);
			
			plugin(context);	
			
			context.members = prune(context.members);
		}
			
		var ret = (constructor == null || localClass.isInterface) ? [] : [constructor.toHaxe()];
		for (member in context.members)
			ret.push(member.toHaxe());
			
		if (verbose) 
			for (field in ret) 
				Context.warning(Printer.printField('', field), field.pos);
		return ret;
	}
	function getOwnMember(name:String) {
		return 
			if (hasOwnMember(name)) 
				members.get(name);
			else
				null;
	}
	
	function hasOwnMember(name:String) {
		return 
			if (name == 'new')
				constructor != null;
			else
				members.exists(name) && !members.get(name).excluded;		
	}
	function hasSuperField(name:String) {
		if (superFields == null) {
			superFields = new Hash();
			var cl = localClass.superClass;
			while (cl != null) {
				var c = cl.t.get();
				for (f in c.fields.get())
					superFields.set(f.name, true);
				cl = c.superClass;
			}
		}
		return superFields.get(name);
	}
	function hasMember(name:String) {
		return hasOwnMember(name) || hasSuperField(name);
	}
	function addMember(to:Array<Member>, m:Member) {
		if (hasOwnMember(m.name)) 
			m.pos.error('duplicate member declaration ' + m.name);
			
		if (m.name == 'new') 
			this.constructor = new Constructor(localClass.isInterface, Enums.enumParameters(m.kind)[0], m.isPublic, m.pos);
		else {
			members.set(m.name, m);
			to.push(m);				
		}
		return m;
	}		
}