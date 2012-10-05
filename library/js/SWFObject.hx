package js;

import js.Dom;

@:native("swfobject") extern class SWFObject
{
	static function __init__() : Void
	{
		haxe.macro.Tools.includeFile("js/SWFObject.js");
	}
	
	static var ua :
	{
		/**
		 * a Boolean whether or not W3C DOM methods are supported 
		 */
		var w3 : Bool;
		
		/**
		 * an Array that contains the major, minor and release version number of the Flash Player 
		 */
		var pv : Array<Int>;
		
		/**
		 * the Webkit version or false if not Webkit 
		 */
		var wk : Bool;
		
		/**
		 * a Boolean to indicate whether a visitor uses Internet Explorer on Windows or not 
		 */
		var ie : Bool;
		
		var win : Bool;
		
		var mac : Bool;
	};
	
	static function registerObject(objectIdStr:String, swfVersionStr:String, xiSwfUrlStr:String, callbackFn:{ success:Bool, id:String, ref:HtmlDom }->Void) : Void;
	static function getObjectById(objectIdStr:String) : HtmlDom;
	static function embedSWF(swfUrlStr:String, replaceElemIdStr:String, widthStr:String, heightStr:String, swfVersionStr:String, xiSwfUrlStr:String, flashvarsObj:Dynamic, parObj:Dynamic, attObj:Dynamic, callbackFn:{ success:Bool, id:String, ref:HtmlDom }->Void) : Void;
	static function getFlashPlayerVersion() : { major:Int, minor:Int, release:Int };
	static function hasFlashPlayerVersion(versionStr:String) : Bool;
	static function addLoadEvent(fn:Void->Void) : Void;
	static function addDomLoadEvent(fn:Void->Void) : Void;
	static function createSWF(attObj:Dynamic, parObj:Dynamic, replaceElemIdStr:String) : HtmlDom;
	static function removeSWF(objElemIdStr:String) : Void;
	static function createCSS(selStr:String, declStr:String, mediaStr:String, newStyleBoolean:Bool) : Void;
	static function getQueryParamValue(paramStr:String) : String;
	static function switchOffAutoHideShow() : Void;
	static function showExpressInstall(att:Dynamic, par:Dynamic, replaceElemIdStr:String, callbackFn:{ success:Bool, id:String, ref:HtmlDom }->Void) : Void;
}
