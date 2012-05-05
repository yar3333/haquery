package haquery.base;

class HaqComponentTools 
{
	public static function getTemplateClass(componentClass:Class<Dynamic>) : Class<Dynamic>
	{
		if (componentClass == null) return null;
		
		var className = Type.getClassName(componentClass);
		var n = className.lastIndexOf(".");
		if (n > 0)
		{
			#if !client
			var templateClassName = className.substr(0, n) + ".TemplateServer";
			#else
			var templateClassName = className.substr(0, n) + ".TemplateClient";
			#end
			var templateClass = Type.resolveClass(templateClassName);
			if (templateClass != null)
			{
				return templateClass;
			}
			else
			{
				return getTemplateClass(Type.getSuperClass(componentClass));
			}
		}
		
		return null;
	}
}