using System;
using System.Collections.Generic;
using System.Text;

namespace haquery_net.hant
{
    class Log 
    {
        int verboseLevel;
        int level;
        
        bool inBlock;
        
        Dictionary<int,string> messages;
        
        public Log(int verboseLevel) 
        {
            this.verboseLevel = verboseLevel;
            level = -1;
            inBlock = false;
            messages = new Dictionary<int,string>();
        }
        
        string indent(int level)
        {
            return new String(' ', level * 2);
        }
        
        public void start(string message)
        {
            level++;
            if (level < verboseLevel)
            {
                if (inBlock) Console.WriteLine("");
                Console.Write(indent(level) + message + ": ");
                inBlock = true;
            }
            messages[level] = message;
        }
        
        public void finishOk()
        {
            if (level < verboseLevel)
            {
                if (!inBlock) Console.Write(indent(level + 1));
                Console.WriteLine("[OK]");
                inBlock = false;
            }
            
            level--;
        }
        
        public void finishFail(string message)
        {
            if (level < verboseLevel)
            {
                if (!inBlock) Console.Write(indent(level + 1));
                Console.WriteLine("[FAIL]");
                inBlock = false;
            }
            
            level--;
            throw level + 1 < verboseLevel
                ? new Exception(message)
                : new Exception(messages[level + 1] + " (" + message + ")");
        }
    }
}