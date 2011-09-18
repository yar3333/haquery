package haquery;

import neko.io.File;
import neko.io.FileOutput;
import neko.io.Path;
import neko.Sys;
import neko.FileSystem;

using StringTools;

class Tasks 
{
    var hant : hant.Tasks;
    
    public function new()
    {
        hant = new hant.Tasks();
    }
    
    function genImports()
    {
        var fo : FileOutput = File.write("src/Imports.hx", false);
        
        for (path in getClassPaths())
        {
            fo.writeString("// " + path + "\n");
            genImportsInner(fo, path);
            fo.writeString("\n");
        }
        
        fo.close();
    }
    
    function genImportsInner(fo:FileOutput, srcPath:String)
    {
        var serverImports = hant.findFiles(srcPath, isServerFile);
        var clientImports = hant.findFiles(srcPath, isClientFile);
        
        fo.writeString("#if php\n");
        fo.writeString(Lambda.map(serverImports, callback(file2import, srcPath)).join('\n'));
        fo.writeString("\n#else\n");
        fo.writeString(Lambda.map(clientImports, callback(file2import, srcPath)).join('\n'));
        fo.writeString("\n#end\n");
        
    }
    
    function isServerFile(path:String)
    {
        if (FileSystem.isDirectory(path))
        {
            return !path.endsWith('.svn');
        }
        return path.endsWith('/Server.hx') || path.endsWith('/Bootstrap.hx');
    }
    
    function isClientFile(path:String)
    {
        if (FileSystem.isDirectory(path))
        {
            return !path.endsWith('.svn');
        }
        return path.endsWith('/Client.hx');
    }
    
    function isSupportFile(path:String)
    {
        if (FileSystem.isDirectory(path))
        {
            return !path.endsWith('.svn');
        }
        return !path.endsWith('.hx') && !path.endsWith('.hxproj');
    }
    
    function file2import(base:String, file:String) : String
    {
        if (file.startsWith(base))
        {
            file = file.substr(base.length + 1);
        }
        
        return "import " + Path.withoutExtension(file).replace('/', '.') + ';';
    }
    
    public function getClassPaths()
    {
        var r : Array<String> = new Array<String>();
        var files = FileSystem.readDirectory('');
        for (file in files)
        {
            if (file.endsWith('.hxproj'))
            {
                var xml = Xml.parse(File.getContent(file));
                var fast = new haxe.xml.Fast(xml.firstElement());
                if (fast.hasNode.classpaths)
                {
                    var cp = fast.node.classpaths;
                    for (elem in cp.elements)
                    {
                        if (elem.name == 'class' && elem.has.path)
                        {
                            r.push(elem.att.path.replace('\\', '/'));
                            trace(elem.att.path);
                        }
                    }
                }
            }
        }
        return r;
    }
    
    // -------------------------------------------------------------------------------
    
    function buildJs()
    {
        hant.createDirectory('bin/haquery/client');
        
        var params = new Array<String>();
        for (path in getClassPaths())
        {
            params.push('-cp'); params.push(path);
        }
        params.push('-js');
        params.push('bin/haquery/client/haquery.js');
        params.push('-main'); params.push('Main');
        params.push('-debug');
        
        Sys.command('haxe', params);
    }
    
    public function genOrm(databaseConnectionString:String)
    {
        Sys.command('php', [
            Path.directory(Sys.executablePath()).replace('\\', '/') + '/orm/index.php' 
            ,databaseConnectionString
            ,'src'
        ]);
    }
    
    public function preBuild()
    {
        genImports();
    }
    
    public function postBuild()
    {
        buildJs();
        
        for (path in getClassPaths())
        {
            hant.copyFolderContent(path, 'bin', isSupportFile);
        }
    }
}