package haquery.common;

private class Exception extends stdlib.Exception { override function toString() return message; }

class HaqTemplateNotFoundException extends Exception {}
class HaqTemplateNotFoundCriticalException extends Exception {}
class HaqTemplateRecursiveExtendsException extends Exception {}
class HaqTemplateConfigParseException extends Exception {}
