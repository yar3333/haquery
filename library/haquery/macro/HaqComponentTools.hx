package haquery.macro;

import haxe.macro.Context;
import sys.FileSystem;
import sys.io.File;
import haxe.macro.Compiler;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.Type;
using haxe.macro.TypeTools;
using haquery.macro.HaqMacroTools;

private typedef EventHandler = { name:String, pos:Position, args:Array<FunctionArg> };

class HaqComponentTools 
{
	public static function build() : Array<Field>
	{
		var componentClass = Context.getLocalClass().get();
        var pos = Context.currentPos();
		
		if (componentClass.name == "Server" || componentClass.name == "Client")
		{
			var fields = Context.getBuildFields();
			var handlers = getComponentClassHandlers(fields);
			
			setComponentClassEventHandlersArgTypes(componentClass, handlers);
			
			if (!Context.defined("display") && componentClass.name == "Server")
			{
				bindServerEventHandlersToConfigClientClass(componentClass, handlers);
			}
			
			return fields;
		}
		
		return null;
	}
	
	public static function template(ethis:Expr)
	{
		switch (Context.follow(Context.typeof(ethis)))
		{
			case Type.TInst(t, params):
				var clas = t.get();
				if (clas.isExtendsFrom("haquery.base.HaqComponent"))
				{
					var typePath = { sub:null, params:[], pack:clas.pack, name:"Template" + clas.name };
					return { expr:ExprDef.ENew(typePath, [ ethis ]), pos:ethis.pos };
				}
				else
				{
					Context.error("Error: call template() macro with a bad class not extends from haquery.base.HaqComponent ('" + Std.string(clas) + "').", ethis.pos);
				}
			default:
		}
		Context.error("Error: call template() macro with a bad type '" + Std.string(Context.typeof(ethis)) + "'.", ethis.pos);
		return null;
	}
	
	public static function shared(ethis:Expr) : Expr
	{
		if (!Context.defined("haqueryGenCode"))
		{
			switch (Context.follow(Context.typeof(ethis)))
			{
				case Type.TInst(t, params):
					var clas = t.get();
					if (clas.isExtendsFrom("haquery.client.HaqComponent"))
					{
						return { expr:ExprDef.ENew(HaqMacroTools.makeTypePath(clas.pack, "SharedServer"), [ ethis ]), pos:ethis.pos };
					}
					else
					if (clas.isExtendsFrom("haquery.server.HaqComponent"))
					{
						return { expr:ExprDef.ENew(HaqMacroTools.makeTypePath(clas.pack, "SharedClient"), [ ethis ]), pos:ethis.pos };
					}
				default:
			}
			
			Context.error("Shared class not found.", Context.currentPos());
			return null;
		}
		else
		{
			return ExprDef.EUntyped(ExprDef.EObjectDecl([]).at(ethis.pos)).at(ethis.pos);
		}
	}
	
	static function setComponentClassEventHandlersArgTypes(componentClass:ClassType, handlers:Array<EventHandler>)
	{
		if (handlers != null && handlers.length > 0)
		{
			Context.getModule(componentClass.pack.join(".") + ".Template" + componentClass.name);
			var templateClass = Context.getType(componentClass.pack.join(".") + ".Template" + componentClass.name).getClass();
			if (templateClass != null)
			{
				for (handler in handlers)
				{
					handler.args[0].type = ComplexType.TPath( { sub:null, params:[], pack:[ "haquery", (componentClass.name == "Server" ? "server" : "client") ], name:"HaqComponent" } );
						
					var splittedHandlerName = handler.name.split("_");
					var templateFieldName = splittedHandlerName.slice(0, splittedHandlerName.length - 1).join("_");
					var eventName = splittedHandlerName[splittedHandlerName.length - 1];
					
					var templateClassFieldClass = getTemplateClassFieldClass(templateClass, templateFieldName);
					if (templateClassFieldClass != null)
					{
						var eventParamType = null;
						var typePath = templateClassFieldClass.pack.join(".") + "." + templateClassFieldClass.name;
						if (typePath == "haquery.client.HaqQuery" || typePath == "js.JQuery")
						{
							eventParamType = HaqMacroTools.getModuleType("js.JQuery", "JqEvent");
						}
						else
						if (typePath == "haquery.server.HaqQuery")
						{
							eventParamType = Context.getType("Dynamic");
						}
						else
						{
							eventParamType = getComponentClassEventClassParamType(templateClassFieldClass, eventName);
						}
						
						if (eventParamType != null)
						{
							handler.args[1].type = eventParamType.toComplexType();
						}
					}
					else
					{
						Context.error("Field '" + templateFieldName + "' not found in template.", handler.pos);
					}
				}
			}
			else
			{
				Context.error("To use handlers you need to have Template" + componentClass.name + " class. Check file 'template.html' existance.", componentClass.pos);
			}
		}
	}
	
	static function getComponentClassHandlers(fields:Array<Field>) : Array<EventHandler>
	{
		var handlers : Array<{ name:String, pos:Position, args:Array<FunctionArg> }> = [];
		
		for (field in fields)
		{
			switch (field.kind)
			{
				case FieldType.FFun(f):
					if (field.name.indexOf("_") > 0 && !StringTools.startsWith(field.name, "get_") && !StringTools.startsWith(field.name, "set_"))
					{
						//Context.warning("Handler found: " + field.name, field.pos);
						if (f.args.length == 2)
						{
							if (f.args[0].type == null && f.args[1].type == null)
							{
								handlers.push({ name:field.name, pos:field.pos, args:f.args });
							}
							else
							{
								Context.error("Event handler's arguments types must not be specified.", field.pos);
								return null;
							}
						}
						else
						{
							Context.error("Event handler must be defined with exactly two arguments.", field.pos);
							return null;
						}
					}
				
				default:
			}
		}
		
		return handlers;
	}
	
	static function getComponentClassEventClassParamType(componentClass:ClassType, eventName:String) : Type
	{
		for (field in componentClass.fields.get())
		{
			if (field.name == "event_" + eventName)
			{
				switch (field.type)
				{
					case Type.TInst(t, params):
						if (t.get().pack.join(".") + "." + t.get().name == "haquery.common.HaqEvent")
						{
							if (params != null && params.length == 1)
							{
								return params[0];
							}
							else
							{
								Context.error("Event's class must have param.", field.pos);
								return null;
							}
						}
						else
						{
							Context.error("Event field type must be 'haquery.common.HaqEvent<param>'.", field.pos);
							return null;
						}
					
					default:
						Context.error("Unexpected event field '" + componentClass.pack.join(".") + "." + componentClass.name + "." + field.name + "' type ('" + Std.string(field.type) + "').", field.pos);
						return null;
				}
			}
		}
		
		if (componentClass.superClass != null)
		{
			return getComponentClassEventClassParamType(componentClass.superClass.t.get(), eventName);
		}
		
		return null;
	}
	
	static function getTemplateClassFieldClass(templateClass:ClassType, fieldName:String) : ClassType
	{
		for (field in templateClass.fields.get())
		{
			if (field.name == fieldName)
			{
				switch (field.type)
				{
					case Type.TType(defTypeRef, _):
						switch (defTypeRef.get().type)
						{
							case Type.TInst(t, _):
								return t.get();
							
							default:
								Context.error("Field(2) '" + field.name + "' of '" + templateClass.pack.join(".") + "." + templateClass.name + "' must have a class type ('" + Std.string(defTypeRef.get().type) + "').", field.pos);
								return null;
						}
					
					case Type.TInst(t, _):
						return t.get();
						
					default:
						Context.error("Field(1) '" + field.name + "' of '" + templateClass.pack.join(".") + "." + templateClass.name + "' must have a class type ('" + Std.string(field.type) + "').", field.pos);
						return null;
				}
			}
		}
		return null;
	}
	
	static function bindServerEventHandlersToConfigClientClass(componentClass:ClassType, handlers:Array<EventHandler>)
	{
		var serverEvents = [ 'click', 'change' ];   // server events
		
		if (handlers == null) handlers = [];
		
		handlers = Lambda.array(Lambda.filter(handlers, function(h)
		{
			var event = h.name.substr(h.name.indexOf("_") + 1);
			return Lambda.has(serverEvents, event);
		}));
		
		var path = "gen/" + componentClass.pack.join("/") + "/ConfigClient.hx";
		var text = File.getContent(path);
		text = StringTools.replace(text
			, "// SERVER_HANDLERS"
			, "public static var serverHandlers = [ " + Lambda.map(handlers, function(h) return "'" + h.name + "'").join(", ") + " ];"
		);
		File.saveContent(path, text);
	}
}
