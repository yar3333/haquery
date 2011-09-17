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
        
        fo.writeString("// HaQuery imports\n");
        genImportsInner(fo, getPathToHaQueryLib() + '/src');
        
        fo.writeString("\n");
        
        fo.writeString("// Project imports\n");
        genImportsInner(fo, 'src');
        
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
        if (FileSystem.isDirectory(path) && !path.endsWith('.svn')) return true;
        return path.endsWith('/Server.hx') || path.endsWith('/Bootstrap.hx');
    }
    
    function isClientFile(path:String)
    {
        if (FileSystem.isDirectory(path) && !path.endsWith('.svn')) return true;
        return path.endsWith('/Client.hx');
    }
    
    function isSupportFile(path:String)
    {
        if (FileSystem.isDirectory(path) && !path.endsWith('.svn')) return true;
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
    
    function getPathToHaQueryLib()
    {
        return Sys.getEnv('HAQUERYPATH');
    }
    
    // -------------------------------------------------------------------------------
    
    function buildJs()
    {
        /*
        <mkdir dir="${dest.dir}${file.separator}haquery${file.separator}client" />
    	<exec executable="haxe">
    	    <arg value="-cp"/><arg value="${lib.dir}${file.separator}src"/>
    	    <arg value="-cp"/><arg value="${src.dir}"/>
    	    <arg value="-js"/>
    	    <arg value="${dest.dir}${file.separator}haquery${file.separator}client${file.separator}haquery.js"/>
    	    <arg value="-main"/><arg value="Main"/>
    	    <arg value="-debug"/>
    	</exec>
        */
        
        FileSystem.createDirectory('bin/haquery/client');
        Sys.command('haxe', [
             '-cp', getPathToHaQueryLib() + '/src'
            ,'-cp', 'src'
            ,'-js'
            ,'bin/haquery/client/haquery.js'
            ,'-main', 'Main'
            ,'-debug'
        ]);
    }
    
    public function genOrm(databaseConnectionString:String)
    {
        /*
   		<exec executable="php">
    	    <arg value="${lib.dir}${file.separator}tools${file.separator}OrmGenerator${file.separator}bin${file.separator}index.php"/>
    	    <arg value="${database.connection}"/>
    	    <arg value="${src.dir}"/>
    	</exec>
        */
        Sys.command('php', [
             getPathToHaQueryLib() + '/tools/OrmGenerator/bin/index.php' 
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
        /*<target name="post-build">
            <antcall target="build-js" />
            <antcall target="copy-support-files">
                <param name="path.from" value="${lib.dir}${file.separator}src" />
                <param name="path.to" value="${dest.dir}" />
            </antcall>
            <antcall target="copy-support-files">
                <param name="path.from" value="${src.dir}" />
                <param name="path.to" value="${dest.dir}" />
            </antcall>
        </target>*/
        
        buildJs();
        
        hant.copyFolderContent(getPathToHaQueryLib() + '/src', 'bin', isSupportFile);
        hant.copyFolderContent('src', 'bin', isSupportFile);
    }
}