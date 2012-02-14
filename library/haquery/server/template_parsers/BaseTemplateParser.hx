package haquery.server.template_parsers;

class BaseTemplateParser implements ITemplateParser
{
	public function getDocAndCss() : { css:String, doc:HaqXml } { throw "Method must be overriden."; return null; }
	public function getServerClass() : Class<HaqComponent> { throw "Method must be overriden."; return null; }
	public function getSupportFilePath(fileName:String) : String { throw "Method must be overriden."; return null; }
	public function getCollectionName() : String { throw "Method must be overriden."; return null; }
	public function getExtendsCollectionName() : String { throw "Method must be overriden."; return null; }
	
	public function getServerHandlers() : Hash<Array<String>>
	{
        Lib.profiler.begin('parseServerHandlers');
            var serverMethods = [ 'click','change' ];   // server events
            var serverHandlers : Hash<Array<String>> = new Hash<Array<String>>();
            var tempObj = Type.createEmptyInstance(getServerClass());
            for (field in Reflect.fields(tempObj))
            {
                if (Reflect.isFunction(Reflect.field(tempObj, field)))
                {
                    var parts = field.split('_');
                    if (parts.length == 2 && Lambda.has(serverMethods, parts[1]))
                    {
                        var nodeID = parts[0];
                        var method = parts[1];
                        if (!serverHandlers.exists(nodeID))
						{
							serverHandlers.set(nodeID, new Array<String>());
						}
                        serverHandlers.get(nodeID).push(method);
                    }
                }
            }
        Lib.profiler.end();
		
		return serverHandlers;
	}
}