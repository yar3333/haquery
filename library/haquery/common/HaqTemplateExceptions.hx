package haquery.common;

private class Exception extends stdlib.Exception
{
	override function toString() return message;
}

class HaqTemplateCriticalException extends Exception {}

class HaqTemplateNotFoundException extends Exception {}

class HaqTemplateNotFoundCriticalException extends HaqTemplateCriticalException
{
	public var componentTag(default, null) : String;
	public var containerTag(default, null) : String;
	
	public function new(componentTag:String, containerTag:String)
	{
		super("Component [ " + componentTag + " ] used in [ " + containerTag + " ] is not found.");
		
		this.componentTag = componentTag;
		this.containerTag = containerTag;
	}
}

class HaqTemplateRecursiveExtendsException extends Exception {}

class HaqTemplateConfigParseException extends Exception {}
