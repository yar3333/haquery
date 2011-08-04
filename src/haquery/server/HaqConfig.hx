#if php
package haquery.server;
/**
 * Хранит настройки приложения.
 * Реальные настройки следует прописывать в отдельных файлах в папке /configs сайта.<br />
 * Например, в файле настроек по-умолчанию /configs/default.php:<br />
 * <code>
 * <?php<br />
 * HaQuery::$config->dbType = 'mysql';<br />
 * HaQuery::$config->isTraceProfiler = true;<br />
 * ?>
 * </code>
 * <br />
 * HaQuery выбирает активный файл настроек по имени домена сайта. Например, если ваш сайт
 * имеет адрес mysite.com, то система будет использовать файл /configs/mysite.com.php, а если
 * его нет - файл /configs/default.php.
 */
class HaqConfig
{
    /**
     * Настройки подключения к БД: тип СУБД (например, 'mysql').
     */
    public var dbType : String;

    /**
     * Настройки подключения к БД: hostname или IP сервера СУБД.
     */
    public var dbServer : String;

    /**
     * Настройки подключения к БД: имя пользователя.
     */
    public var dbUsername : String;

    /**
     * Настройки подключения к БД: пароль.
     */
    public var dbPassword : String;

    /**
     * Настройки подключения к БД: имя БД.
     */
    public var dbDatabase : String;

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
     * Считать ли ошибки выполнения SQL-запросов критичными и, соответственно,
     * прерывать ли выполнение скрипта, когда такая ошибка возникает.
     */
    public var stopOnSqlError : Bool;

    /**
     * Логгировать ли информацию о загрузке компонентов.
     */
    public var isTraceComponent : Bool;

    /**
     * Логгировать ли информацию о скорости работы.
     */
    public var isTraceProfiler : Bool;

    /**
     * Выводить в лог только если IP пользователя равен данному (пустое поле означает выводить всё).
     */
    public var traceFilter_IP : String;

    /**
     * Произвольные данные.
     */
    public var custom : Dynamic;

    /**
     * Ассоциативный массив ключей и значений 
     * для подстановки в исходный HTML-текст страницы.
     * @var array 
     */
    public var consts : Hash<String>;
	
	public var componentsFolders(default, null) : Array<String>;
	
	public function new() : Void
	{
		dbType = '';
		dbServer = '';
		dbUsername = '';
		dbPassword = '';
		dbDatabase = '';
		autoSessionStart = true;
		autoDatabaseConnect = true;
		sqlTraceLevel = 1;
		stopOnSqlError = true;
		isTraceComponent = false;
		isTraceProfiler = false;
		traceFilter_IP = '';
		custom = null;
		consts = new Hash<String>();
		componentsFolders = new Array<String>();
	}
}
#end
