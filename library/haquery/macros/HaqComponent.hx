package haquery.macros;

import haxe.macro.Context;
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
			//Context.warning("Build class " + componentClass.pack.join(".") + componentClass.name, pos);
			
			var fields = Context.getBuildFields();
			
			var handlers = getComponentClassHandlers(fields);
			if (handlers != null && handlers.length > 0)
			{
				var templateClass = getTemplateClass(componentClass);
				if (templateClass != null)
				{
					for (handler in handlers)
					{
						handler.f.args[0].type = ComplexType.TPath( { sub:null, params:[], pack:[ "haquery", (componentClass.name == "Server" ? "server" : "client") ], name:"HaqComponent" } );
							
						var splittedHandlerName = handler.name.split("_");
						var templateFieldName = splittedHandlerName.slice(0, splittedHandlerName.length - 1).join("_");
						var eventName = splittedHandlerName[splittedHandlerName.length - 1];
						
						var getTemplateClassFieldClass = getTemplateClassFieldClass(templateClass, templateFieldName);
						if (getTemplateClassFieldClass != null)
						{
							var eventParamType = getComponentClassEventClassParamType(getTemplateClassFieldClass, eventName);
							if (eventParamType != null)
							{
								Context.warning("Type = " + eventParamType, handler.pos);
								var resultType = tink.macro.tools.TypeTools.toComplex(eventParamType);
								if (resultType != null)
								{
									handler.f.args[1].type = resultType;
								}
								else
								{
									Context.error("Can't convert field type to complex (" + eventParamType + ").", pos);
								}
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
					Context.error("To use handlers you need to have Template" + componentClass.name + " class. Check file 'template.html' existance.", pos);
				}
			}
			
			return fields;
		}
		
		return null;
	}
	
	static function getComponentClassHandlers(fields:Array<Field>) : Array<{ name:String, pos:Position, f:Function }>
	{
		#if macro
		
		var handlers : Array<{ name:String, pos:Position, f:Function }> = [];
		
		for (field in fields)
		{
			if (Lambda.exists(field.meta, function(m) return m.name == "handler"))
			{
				Context.warning("Handler found: " + field.name, field.pos);
				
				switch (field.kind)
				{
					case FieldType.FFun(f):
						if (field.name.indexOf("_") > 0)
						{
							if (f.args.length == 2)
							{
								if (f.args[0].type == null && f.args[1].type == null)
								{
									handlers.push({ name:field.name, pos:field.pos, f:f });
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
		
		#else
		
		throw "Not supported.";
		return null;
		
		#end
	}
	
	static function getComponentClassEventClassParamType(componentClass:ClassType, eventName:String) : Type
	{
		#if macro
		
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
								Context.getModule(t.get().module);
								Context.warning("Event's param is " + params[0] + ".", field.pos);
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
		
		#else
		
		throw "Not supported.";
		return null;
		
		#end
	}
	
	static function getTemplateClass(componentClass:ClassType) : ClassType
	{
		#if macro
		
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
		
		#else
		
		throw "Not supported.";
		return null;
		
		#end
	}
	
	static function getTemplateClassFieldClass(templateClass:ClassType, fieldName:String) : ClassType
	{
		#if macro
		
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
		
		#else
		
		throw "Not supported.";
		return null;
		
		#end
	}
}