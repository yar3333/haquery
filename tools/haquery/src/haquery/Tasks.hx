package haquery;

import neko.io.File;
import neko.io.FileOutput;
import neko.io.Path;
import neko.Sys;
import neko.Lib;
import neko.FileSystem;

using StringTools;

class Tasks 
{
    var log : hant.Log;
    var hant : hant.Tasks;
    
    public function new()
    {
        log = new hant.Log(2);
        hant = new hant.Tasks(log);
    }
    
    function genImports()
    {
        log.start("Generate imports to 'src/Imports.hx'");
        
        var fo : FileOutput = File.write("src/Imports.hx", false);
        
        for (path in getClassPaths())
        {
            fo.writeString("// " + path + "\n");
            genImportsInner(fo, path);
            fo.writeString("\n");
        }
        
        fo.close();
        
        log.finishOk();
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
        log.start("Build client to 'bin/haquery/client/haquery.js'");
        
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
        
        log.finishOk();
    }
    
    public function genOrm(databaseConnectionString:String)
    {
        log.start("Generate ORM classes to 'models'");
        
        Sys.command('php', [
            Path.directory(Sys.executablePath()).replace('\\', '/') + '/orm/index.php' 
            ,databaseConnectionString
            ,'src'
        ]);
        
        log.finishOk();
    }
    
    public function preBuild()
    {
        log.start("Do pre-build step");
        
        genImports();
        
        log.finishOk();
    }
    
    public function postBuild()
    {
        log.start("Do post-build step");
        
        buildJs();
        
        for (path in getClassPaths())
        {
            hant.copyFolderContent(path, 'bin', isSupportFile);
        }
        
        log.finishOk();
    }
    
    public function getHaxePath()
    {
        var r = Sys.getEnv('HAXEPATH');
        
        if (r == null)
        {
            throw "HaXe not found (HAXEPATH environment variable not set).";
        }
        
        while (r.endsWith('\\') || r.endsWith('/'))
        {
            r = r.substr(0, r.length - 1);
        }
        r += '\\';
        
        
        if (!FileSystem.exists(r + 'haxe.exe'))
        {
            throw "HaXe not found (file '" + r + "haxe.exe' do not exist).";
        }
        
        return r;
    }
    
    public function install()
    {
        log.start('Install HaxeMod');
        
        var haxePath = getHaxePath();
        
        if (!FileSystem.exists(haxePath + 'haxe.exe.official'))
        {
            hant.rename(haxePath + 'haxe.exe', haxePath + 'haxe.exe.official');
        }
        File.copy(Path.directory(Sys.executablePath()) + '\\haxemod\\haxe.exe', haxePath + 'haxe.exe');
        
        if (!FileSystem.exists(haxePath + 'std.official'))
        {
            hant.rename(haxePath + 'std', haxePath + 'std.official');
            hant.copyFolderContent(Path.directory(Sys.executablePath()) + '\\haxemod\\std', haxePath + 'std', function(s) { return true; } );
        }
        
        log.finishOk();
    }
    
    public function uninstall()
    {
        log.start('Uninstall HaxeMod');
        
        var haxePath = getHaxePath();
        
        if (!FileSystem.exists(haxePath + 'haxe.exe.official'))
        {
            log.finishFail("HaxeMod does not installed.");
        }
        hant.rename(haxePath + 'haxe.exe.official', haxePath + 'haxe.exe');
        
        if (FileSystem.exists(haxePath + 'std.official'))
        {
            hant.deleteDirectory(haxePath + 'std');
            hant.rename(haxePath + 'std.official', haxePath + 'std');
        }
        
        log.finishOk();
    }
}