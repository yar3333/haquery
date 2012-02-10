package hant;

import neko.Lib;

class Log 
{
    var verboseLevel : Int;
    var level : Int;
    
    var inBlock : Bool;
    
    var messages : IntHash<String>;
    
    public function new(verboseLevel:Int) 
    {
        this.verboseLevel = verboseLevel;
        level = -1;
        inBlock = false;
        messages = new IntHash<String>();
    }
    
    function indent(level:Int) : String
    {
        return StringTools.rpad('', ' ', level * 2);
    }
    
    public function start(message:String)
    {
        level++;
        if (level < verboseLevel)
        {
            if (inBlock) Lib.println("");
            Lib.print(indent(level) + message + ': ');
            inBlock = true;
        }
        messages.set(level, message);
    }
    
    public function finishOk()
    {
        if (level < verboseLevel)
        {
            if (!inBlock) Lib.print(indent(level + 1));
            Lib.println("[OK]");
            inBlock = false;
        }
        
        level--;
    }
    
    public function finishFail(message:String)
    {
        if (level < verboseLevel)
        {
            if (!inBlock) Lib.print(indent(level + 1));
            Lib.println("[FAIL]");
            inBlock = false;
        }
        
        level--;
        throw level + 1 < verboseLevel
            ? message 
            : messages.get(level + 1) + " (" + message + ")";
    }
}