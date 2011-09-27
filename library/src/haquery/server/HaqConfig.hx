#if php
package haquery.server;

using haquery.StringTools;

/**
 * Хранит настройки приложения.
 * Реальные настройки следует прописывать в отдельных файлах в папке /configs сайта.<br />
 * Например, в файле настроек по-умолчанию /configs/default.php:<br />
 * <code>
 * <?php<br />
 * HaQuery.config.db.type = 'mysql';<br />
 * HaQuery.config.isTraceProfiler = true;<br />
 * ?>
 * </code>
 * <br />
 * HaQuery выбирает активный файл настроек по имени домена сайта. Например, если ваш сайт
 * имеет адрес mysite.com, то система будет использовать файл /configs/mysite.com.php, а если
 * его нет - файл /configs/default.php.
 */
class HaqConfig
{
    public var db : { type:String, host:String, user:String, pass:String, database:String };
	
    /**
     * Вызывать ли session_start() при старте.
     */
    public var autoSessionStart : Bool;

    /**
     * Вызывать ли HaqDb::connetc() при старте.
     */
    public var autoDatabaseConnect : Bool;

    /**
     * Задаёт насколько подробно выводить в лог информацию о SQL:
     * 0 - не показывать;
     * 1 - показывать только ошибки;
     * 2 - всегда показывать запросы;
     * 3 - всегда показывать запросы и данные о результатах их выполнения.
     */
    public var sqlTraceLevel : Int;

    /**
     * Логгировать ли информацию о загрузке компонентов.
     */
    public var isTraceComponent : Bool;

    /**
     * Выводить в лог только если IP пользователя равен данному (пустое поле означает выводить всё).
     */
    public var filterTracesByIP : String;

    /**
     * Произвольные данные.
     */
    public var custom : Dynamic;

	var componentsFolders : Array<String>;
    
    public function addComponentsFolder(path:String) : Void
    {
        componentsFolders.push(path.replace('\\', '/').trim('/'));
    }
    
    public function getComponentsFolders() : Array<String>
    {
        return componentsFolders;
    }
    
    /**
     * Path to layout file (null if layout do not need).
     */
    public var layout : String;
	
	public function new() : Void
	{
		db = {
			 type : null
			,host : null
			,user : null
			,pass : null
			,database : null
		};
		autoSessionStart = true;
		autoDatabaseConnect = true;
		sqlTraceLevel = 1;
		isTraceComponent = false;
		filterTracesByIP = '';
		custom = null;
		componentsFolders = [ 'haquery/components' ];
        layout = null;
	}
}
#end
