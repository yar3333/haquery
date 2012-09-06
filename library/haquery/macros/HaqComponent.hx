package haquery.macros;

#if macro
import haxe.macro.Context;
#end

import haxe.macro.Expr;
import haxe.macro.Type;

class HaqComponent
{
	@:macro public function template(ethis:Expr)
	{
		var pos = Context.currentPos();
		
		switch (Context.typeof(ethis))
		{
			case Type.TInst(t, params):
				var clas = t.get();
				if (clas.pack.length > 0 && (clas.pack[0] == "components" || clas.pack[0] == "pages") && (clas.name == "Server" || clas.name == "Client"))
				{
					var typePath = { sub:null, params:[], pack:clas.pack, name:"Template" + clas.name };
					return { expr:ExprDef.ENew(typePath, [ ethis ]), pos:pos };
				}
			default:
		}
		
		return Context.makeExpr(null, pos);
	}
	
	@:macro public static function build() : Array<Field>
	{
		var componentClass = Context.getLocalClass().get();
        var pos = Context.currentPos();
		
		if (componentClass.name == "Server" || componentClass.name == "Client")
		{
			var fields = Context.getBuildFields();
			setComponentClassEventHandlersArgTypes(componentClass, fields);
			return fields;
		}
		else
		{
			log("SKIPPED: " + componentClass.pack.join(".") + "." + componentClass.name);
		}
		
		return null;
	}
	
	#if macro
	
	static function log(s:String) : Void
	{
		/*
		if (sys.FileSystem.exists("build.log"))
		{
			var log = sys.io.File.append("build.log", false);
			log.writeString(s + "\n");
			log.close();
		}
		else
		{
			sys.io.File.saveContent("build.log", s + "\n");
		}
		*/
	}
	
	static function setComponentClassEventHandlersArgTypes(componentClass:ClassType, fields:Array<Field>)
	{
		log("setComponentClassEventHandlersArgTypes for class " + componentClass.pack.join(".") + "." + componentClass.name);
		//Context.warning("setComponentClassEventHandlersArgTypes for class " + componentClass.pack.join(".") + componentClass.name, componentClass.po);
		
		var handlers = getComponentClassHandlers(fields);
		if (handlers != null && handlers.length > 0)
		{
			var templateClass = getTemplateClass(componentClass);
			if (templateClass != null)
			{
				for (handler in handlers)
				{
					handler.args[0].type = ComplexType.TPath( { sub:null, params:[], pack:[ "haquery", (componentClass.name == "Server" ? "server" : "client") ], name:"HaqComponent" } );
						
					var splittedHandlerName = handler.name.split("_");
					var templateFieldName = splittedHandlerName.slice(0, splittedHandlerName.length - 1).join("_");
					var eventName = splittedHandlerName[splittedHandlerName.length - 1];
					
					var getTemplateClassFieldClass = getTemplateClassFieldClass(templateClass, templateFieldName);
					if (getTemplateClassFieldClass != null)
					{
						var eventParamType = getComponentClassEventClassParamType(getTemplateClassFieldClass, eventName);
						if (eventParamType != null)
						{
							handler.args[1].type = tink.macro.tools.TypeTools.toComplex(eventParamType);
						}
					}
					else
					{
						Context.error("Field '" + templateFieldName + "' is not found in template.", handler.pos);
					}
				}
			}
			else
			{
				Context.error("To use handlers you need to have Template" + componentClass.name + " class. Check file 'template.html' existance.", componentClass.pos);
			}
		}
	}
	
	static function getComponentClassHandlers(fields:Array<Field>) : Array<{ name:String, pos:Position, args:Array<FunctionArg> }>
	{
		var handlers : Array<{ name:String, pos:Position, args:Array<FunctionArg> }> = [];
		
		for (field in fields)
		{
			if (Lambda.exists(field.meta, function(m) return m.name == "handler"))
			{
				//Context.warning("Handler found: " + field.name, field.pos);
				
				switch (field.kind)
				{
					case FieldType.FFun(f):
						if (field.name.indexOf("_") > 0)
						{
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
						else
						{
							Context.error("Event handler's name must have format 'objectID_eventName'.", field.pos);
							return null;
						}
					
					default:
						Context.error("Using @handler is possible with methods only.", field.pos);
						return null;
				}
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
								//Context.getModule(t.get().module);
								//Context.warning("Event's param is " + params[0] + ".", field.pos);
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
	
	static function getTemplateClass(componentClass:ClassType) : ClassType
	{
		var templateClassTypes = Context.getModule(componentClass.pack.join(".") + ".Template" + componentClass.name);
		for (templateClassType in templateClassTypes)
		{
			switch (templateClassType)
			{
				case Type.TInst(templateClassRef, params):
					var templateClass = templateClassRef.get();
					if (templateClass.name == "Template" + componentClass.name)
					{
						return templateClass;
					}
				
				default:
			}
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
	
	#end
}