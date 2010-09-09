package
{
	import flash.net.URLLoader;
	
	public interface IGeneral
	{
		function get fileSeparator():String;
		function get returntourl():String;
		function set returntourl(val:String):void;
		function get keepaliveurl():String;
		function set keepaliveurl(val:String):void;
		function get mdidhelpurl():String;
		function set mdidhelpurl(val:String):void;
		function get mediaviewerhelpurl():String;
		function set mediaviewerhelpurl(val:String):void;
		function get mdidversion():String;
		function set mdidversion(val:String):void;
		function get runmode():String;
		function flashVarItem(theKey:String):String;
		function queryStringItem(theKey:String):String;
		function ensureFolderExists(thePath:String):void;
		function fileExists(thePathName:String):Boolean;
		function ensureFolderSizeUnderMax(maxCacheKB:int):void;
		function writeBinaryFileToCache(theLoader:URLLoader, thePathName:String):void;
		function getDocumentsDirectory():String;
		function getLocalThumbCachePath():String;
		function getLocalCachePath():String;
		function setLocalCachePath(thePath:String):Boolean;
		function getLocalAppDirectory():String;
		function getPrefsFile():String;
		function jumpToUrl(theUrl:String, target:String="_self"):void;
		function toggleFullScreen():void;
		function loadLocalXmlFile(thePathName:String):String;
	}
}