package php.firePHP;

@:native("FirePHP") extern class FirePHP
{
    static function __init__() : Void
	{
		//untyped __php__("require_once 'php/firePHP/FirePHP/Init.php';");
        untyped __php__("require_once 'php/firePHP/FirePHPCore/FirePHP.class.php';");
	}
    
	/**
     * FirePHP version
     */
    static inline public var VERSION : String = '0.3';    // @pinf replace '0.3' with '%%package.version%%'

    /**
     * Firebug LOG level
     * Logs a message to firebug console.
     */
    static inline public var LOG : String = 'LOG';
  
    /**
     * Firebug INFO level
     * Logs a message to firebug console and displays an info icon before the message.
     */
    static inline public var INFO : String = 'INFO';
    
    /**
     * Firebug WARN level
     * Logs a message to firebug console, displays an warning icon before the message and colors the line turquoise.
     */
    static inline public var WARN : String = 'WARN';
    
    /**
     * Firebug ERROR level
     * Logs a message to firebug console, displays an error icon before the message and colors the line yellow. Also increments the firebug error count.
     */
    static inline public var ERROR : String = 'ERROR';
    
    /**
     * Dumps a variable to firebug's server panel
     */
    static inline public var DUMP : String = 'DUMP';
    
    /**
     * Displays a stack trace in firebug console
     */
    static inline public var TRACE : String = 'TRACE';
    
    /**
     * Displays an exception in firebug console
     * Increments the firebug error count.
     */
    static inline public var EXCEPTION : String = 'EXCEPTION';
    
    /**
     * Displays an table in firebug console
     */
    static inline public var TABLE : String = 'TABLE';
    
    /**
     * Starts a group in firebug console
     */
    static inline public var GROUP_START : String = 'GROUP_START';
    
    /**
     * Ends a group in firebug console
     */
    static inline public var GROUP_END : String = 'GROUP_END';

    /**
     * When the object gets serialized only include specific object members.
     */  
    public function __sleep() : NativeArray;
    
    /**
     * Gets singleton instance of FirePHP
     */
    public static function getInstance(AutoCreate:Bool=false) : FirePHP;
    
    /**
     * Creates FirePHP object and stores it for singleton access
     */
    public static function init() : FirePHP;

    /**
     * Set the instance of the FirePHP singleton
     * @param instance The FirePHP object instance
     */
    public static function setInstance(instance:FirePHP) : FirePHP;

    /**
     * Set an Insight console to direct all logging calls to
     * @param console The console object to log to
     */
    public function setLogToInsightConsole(console:Dynamic) : Void;

    /**
     * Enable and disable logging to Firebug
     * @param Enabled TRUE to enable, FALSE to disable
     */
    public function setEnabled(Enabled:Bool) : Void;
    
    /**
     * Check if logging is enabled
     * @return boolean TRUE if enabled
     */
    public function getEnabled() : Bool;
    
    /**
     * Specify a filter to be used when encoding an object
     * Filters are used to exclude object members.
     * @param Class The class name of the object
     * @param Filter An array of members to exclude
     */
    public function setObjectFilter(Class:String, Filter:NativeArray) : Void;
  
    /**
     * Set some options for the library
     * Options:
     *  - maxDepth: The maximum depth to traverse (default: 10)
     *  - maxObjectDepth: The maximum depth to traverse objects (default: 5)
     *  - maxArrayDepth: The maximum depth to traverse arrays (default: 5)
     *  - useNativeJsonEncode: If true will use json_encode() (default: true)
     *  - includeLineNumbers: If true will include line numbers and filenames (default: true)
     * @param Options The options to be set
     */
    public function setOptions(Options:NativeArray) : Void;

    /**
     * Get options from the library
     * @return array The currently set options
     */
    public function getOptions() : NativeArray;

    /**
     * Set an option for the library
     * @throws Exception
     */  
    public function setOption(Name:String, Value:Dynamic) : Void;

    /**
     * Get an option from the library
     * @throws Exception
     */
    public function getOption(Name:String) : Dynamic;

    /**
     * Register FirePHP as your error handler
     * Will throw exceptions for each php error.
     * @return mixed Returns a string containing the previously defined error handler (if any)
     */
    public function registerErrorHandler(throwErrorExceptions:Bool=false) : Dynamic;

    /**
     * FirePHP's error handler
     * Throws exception for each php error that will occur.
     */
    public function errorHandler(errno:Int, errstr:String, errfile:String, errline:Int, errcontext:NativeArray) : Void;
  
    /**
     * Register FirePHP as your exception handler
     * @return mixed Returns the name of the previously defined exception handler,
     *               or NULL on error.
     *               If no previous handler was defined, NULL is also returned.
     */
    public function registerExceptionHandler() : Dynamic;
  
    /**
     * FirePHP's exception handler
     * Logs all exceptions to your firebug console and then stops the script.
     * @throws Exception
     */
    public function exceptionHandler(Exception:Exception) : Void;
  
    /**
     * Register FirePHP driver as your assert callback
     * @return mixed Returns the original setting or FALSE on errors
     */
    public function registerAssertionHandler(convertAssertionErrorsToExceptions:Bool=true, throwAssertionExceptions:Bool=false) : Dynamic;
  
    /**
     * FirePHP's assertion handler
     * Logs all assertions to your firebug console and then stops the script.
     * @param file File source of assertion
     * @param line Line source of assertion
     * @param code Assertion code
     */
    public function assertionHandler(file:String, line:Int, code:Dynamic) : Void;
  
    /**
     * Start a group for following messages.
     * Options:
     *   Collapsed: [true|false]
     *   Color:     [#RRGGBB|ColorName]
     * @param Options OPTIONAL Instructions on how to log the group
     * @throws Exception
     */
    public function group(Name:String, Options:NativeArray=null) : Bool;
  
    /**
     * Ends a group you have started before
     * @throws Exception
     */
    public function groupEnd() : Bool;

    /**
     * Log object with label to firebug console
     * @see FirePHP::LOG
     * @throws Exception
     */
    public function log(Object:Dynamic, Label:String=null, Options:NativeArray=untyped __php__("array()")) : Bool; 

    /**
     * Log object with label to firebug console
     * @see FirePHP::INFO
     * @throws Exception
     */
    public function info(Object:Dynamic, Label:String=null, Options:NativeArray=untyped __php__("array()")) : Bool; 

    /**
     * Log object with label to firebug console
     * @see FirePHP::WARN
     * @throws Exception
     */
    public function warn(Object:Dynamic, Label:String=null, Options:NativeArray=untyped __php__("array()")) : Bool; 

    /**
     * Log object with label to firebug console
     * @see FirePHP::ERROR
     * @throws Exception
     */
    public function error(Object:Dynamic, Label:String=null, Options:NativeArray=untyped __php__("array()")) : Bool; 

    /**
     * Dumps key and variable to firebug server panel
     * @see FirePHP::DUMP
     * @throws Exception
     */
    public function dump(Key:String, Variable:Dynamic, Options:NativeArray=untyped __php__("array()")) : Bool;
  
    /**
     * Log a trace in the firebug console
     * @see FirePHP::TRACE
     * @throws Exception
     */
    public function trace(Label:String) : Bool; 

    /**
     * Log a table in the firebug console
     * @see FirePHP::TABLE
     * @throws Exception
     */
    public function table(Label:String, Table:String, Options:NativeArray=untyped __php__("array()")) : Bool;

    /**
     * Insight API wrapper
     * @see Insight_Helper::to()
     */
    public static function to() : Dynamic;

    /**
     * Insight API wrapper
     * @see Insight_Helper::plugin()
     */
    public static function plugin() : Dynamic;

    /**
     * Check if FirePHP is installed on client
     */
    public function detectClientExtension() : Bool;
 
    /**
     * Log varible to Firebug
     * @see http://www.firephp.org/Wiki/Reference/Fb
     * @param Object The variable to be logged
     * @return true Return TRUE if message was added to headers, FALSE otherwise
     * @throws Exception
     */
    public function fb(Object:Dynamic) : Bool;

    /**
     * Get all request headers
     */
    public static function getAllRequestHeaders() : NativeArray;
  
    /**
     * Encode an object into a JSON string
     * Uses PHP's jeson_encode() if available
     * @param Object The object to be encoded
     * @return string The JSON string
     */
    public function jsonEncode(Object:Dynamic, skipObjectEncode:Bool=false) : String;
}