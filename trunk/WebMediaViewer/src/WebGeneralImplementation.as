package
{
	import flash.display.StageDisplayState;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.controls.*;
	import mx.core.Application;

	public class WebGeneralImplementation implements IGeneral
	{
		private var params:Object;
		private var _mdidversion:String = "";
		private var _keepaliveurl:String = "";
		private var _returntourl:String = "";
		private var _mediaviewerhelpurl:String = "";
		private var _mdidhelpurl:String = "";
		
		public function get mediaviewerhelpurl():String {
			return _mediaviewerhelpurl;
		}
		public function set mediaviewerhelpurl(val:String):void {
			_mediaviewerhelpurl = val;
		}
		public function get mdidhelpurl():String {
			return _mdidhelpurl;
		}
		public function set mdidhelpurl(val:String):void {
			_mdidhelpurl = val;
		}
		public function get fileSeparator():String {
			//browser can't access local filesystem
			throw new Error("This functionality isn't supported in the Web version (fileSeparator).");
		}
		public function get returntourl():String {
			return _returntourl;
		}
		public function set returntourl(val:String):void {
			_returntourl = val;
		}
		public function get keepaliveurl():String {
			return _keepaliveurl;
		}
		public function set keepaliveurl(val:String):void {
			_keepaliveurl = val;
		}
		public function get mdidversion():String {
			return _mdidversion;
		}
		public function set mdidversion(val:String):void {
			_mdidversion = val;
		}
		public function get runmode():String {
			return GeneralFactory.WEB_MODE;	
		}
		public function flashVarItem(theKey:String):String {
			return Application.application.parameters[theKey];
		}
		public function queryStringItem(theKey:String):String {
			if (params == null) {
				try {
		            // Remove everything before the question mark, including
		            // the question mark.
		            var myPattern:RegExp = /.*\?/;  
		            var s:String = ExternalInterface.call("window.location.search.substring", 1);
		            s = s.replace(myPattern, "");
		
	               // Create an Array of name=value Strings.
	                var myArray:Array = s.split("&");
	                params = {};
	 				for (var i:uint=0,index:int=-1; i<myArray.length; i++)
					{
					    var kvPair:String = myArray[i];
					    if ((index = kvPair.indexOf("=")) > 0)
					    {
					        var key:String = kvPair.substring(0,index);
					        var value:String = kvPair.substring(index+1);
					        params[key] = value;
					    }
					}
				} catch (e:Error) {
		            trace(e);
				}
			}
			var returnval:String = "";
			try {
				returnval = params[theKey];
			} catch(e:Error) {
				returnval = "";
			}
			return returnval;
		}
		public function ensureFolderExists(thePath:String):void {
			//browser can't access local filesystem
			throw new Error("This functionality isn't supported in the Web version (ensureFolderExists).");	
		}
		public function fileExists(thePathName:String):Boolean {
			//browser can't access local filesystem
			throw new Error("This functionality isn't supported in the Web version (fileExists).");	
		}
		public function ensureFolderSizeUnderMax(maxCacheKB:int):void {
			//browser can't access local filesystem
			throw new Error("This functionality isn't supported in the Web version (ensureFolderSizeUnderMax).");
		}
		public function writeBinaryFileToCache(theLoader:URLLoader, thePathName:String):void {
			//browser can't access local filesystem
			throw new Error("This functionality isn't supported in the Web version (writeBinaryFileToCache).");
		}
		public function getDocumentsDirectory():String {
			//browser can't access local filesystem
			throw new Error("This functionality isn't supported in the Web version (getDocumentsDirectory).");
		}
		public function getLocalThumbCachePath():String {
			//browser can't access local filesystem
			throw new Error("This functionality isn't supported in the Web version (getLocalThumbCachePath).");
		}
		public function getLocalCachePath():String {
			//browser can't access local filesystem
			throw new Error("This functionality isn't supported in the Web version (getLocalCachePath).");
		}
		public function setLocalCachePath(thePath:String):Boolean {
			//browser can't access local filesystem
			throw new Error("This functionality isn't supported in the Web version (setLocalCachePath).");
		}
		public function getLocalAppDirectory():String {
			//browser can't access local filesystem
			throw new Error("This functionality isn't supported in the Web version (getLocalAppDirectory).");
		}
		public function getPrefsFile():String {
			//browser can't access local filesystem
			throw new Error("This functionality isn't supported in the Web version (getPrefsFile).");
		}
		public function jumpToUrl(theUrl:String, target:String="_self"):void {
            var request:URLRequest = new URLRequest(theUrl);
            navigateToURL(request, target);
        }
        public function toggleFullScreen():void {
             switch(Application.application.stage.displayState) {
                case StageDisplayState.FULL_SCREEN:
                    Application.application.stage.displayState = StageDisplayState.NORMAL;    
                    break;
                case StageDisplayState.NORMAL:
                default:
                    Application.application.stage.displayState = StageDisplayState.FULL_SCREEN;    
                    break;
            }
        }
        public function loadLocalXmlFile(thePathName:String):String {
 			//browser can't access local filesystem
			throw new Error("This functionality isn't supported in the Web version (loadLocalXmlFile).");
        }
	}
}