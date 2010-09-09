package
{
	import flash.display.StageDisplayState;
	import flash.net.URLLoader;
	
	import mdm.Application;
	import mdm.FileSystem;
	import mdm.Forms;
	
	import mx.controls.*;
	import mx.core.Application;

	public class ZincGeneralImplementation implements IGeneral
	{
		private var _mdidversion:String = "";
		private var _keepaliveurl:String = "";
		private var _returntourl:String = "";
		private var _contentPath:String = "";
		private var _windowWithFocus:String = "main";
		private var _isRunningInDualScreenMode:Boolean = false;
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
		
		public function get windowWithFocus():String {
			return _windowWithFocus;
		}
		public function set windowWithFocus(val:String):void {
			_windowWithFocus = val;
		}
		public function get isRunningInDualScreenMode():Boolean {
			return _isRunningInDualScreenMode;
		}
		public function set isRunningInDualScreenMode(val:Boolean):void {
			_isRunningInDualScreenMode = val;
		}
		public function get fileSeparator():String {
			return ""; //File.separator;
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
			return GeneralFactory.ZINC_MODE	
		}
		public function flashVarItem(theKey:String):String {
			throw new Error("This functionality isn't supported in the Zinc version (flashVarItem).");	
		}
		public function queryStringItem(theKey:String):String {
			//Zinc app does not have a URL with QueryString
			throw new Error("This functionality isn't supported in the Zinc version (queryStringItem).");	
		}
		public function ensureFolderExists(thePath:String):void {
			if (!mdm.FileSystem.folderExists(thePath)) {
				try {
					mdm.FileSystem.makeFolder(thePath);
				} catch(e:Error) {
					throw(e);
				}
			}
		}
		public function fileExists(thePathName:String):Boolean {
			return (mdm.FileSystem.fileExists(thePathName));
		}
		public function ensureFolderSizeUnderMax(maxCacheKB:int):void {
			throw new Error("This functionality isn't supported in the Zinc version (ensureFolderSizeUnderMax).");
		}
		public function writeBinaryFileToCache(theLoader:URLLoader, thePathName:String):void {
			//Writing binary data to a file from Zinc is VERY slow and NOT asynchronous.
			//mdm.FileSystem.BinaryFile.setDataBA(loader.data);
			//mdm.FileSystem.BinaryFile.writeDataBA(contentPath + filename);
			throw new Error("This functionality isn't supported in the Zinc version (writeBinaryFileToCache).");
		}
		public function getDocumentsDirectory():String {
			//zinc doesn't need access to UserDirectory
			throw new Error("This functionality isn't supported in the Web version (getDocumentsDirectory).");
		}
		public function getLocalThumbCachePath():String {
			//Zinc is not caching thumbnails
			throw new Error("This functionality isn't supported in the Web version (getLocalThumbCachePath).");
		}
		public function getLocalCachePath():String {
			return this._contentPath;
		}
		public function setLocalCachePath(thePath:String):Boolean {
			var localCachePath:String = mdm.Application.path + thePath;
			if (!mdm.FileSystem.folderExists(localCachePath)) {
				try {
					mdm.FileSystem.makeFolder(localCachePath);
				} catch(e:Error) {
					//e.message = "Package is corrupt. Download another copy from your MDID server.";
					//throw(e);
					return false;
					
				}
			}
			//make sure localCachePath ends with a separator
			var separator:String = mdm.Application.path.charAt(mdm.Application.path.length - 1);
			if (localCachePath.length > 0 && localCachePath.charAt(localCachePath.length) != separator) {
				localCachePath += separator;
			}
			this._contentPath = localCachePath;
			return (this._contentPath.length > 2);
		}
		public function getLocalAppDirectory():String {
			return mdm.FileSystem.getCurrentDir();
		}
		public function getPrefsFile():String {
			throw new Error("This functionality isn't supported in the Zinc version (getPrefsFile).");
		}
		public function jumpToUrl(theUrl:String, target:String="_self"):void {
			throw new Error("This functionality isn't supported in the Zinc version (jumpToUrl).");
		}
        public function toggleFullScreen():void {
             switch(mx.core.Application.application.stage.displayState) {
                case StageDisplayState.FULL_SCREEN:
                    mdm.Forms.getFormByName(Settings.ZINC_FIRST_FORM_NAME).showFullScreen(false);
                    break;
                case StageDisplayState.NORMAL:
                default:
                    mdm.Forms.getFormByName(Settings.ZINC_FIRST_FORM_NAME).showFullScreen(true);
                    break;
            }
        }
        public function loadLocalXmlFile(thePathName:String):String {
			var returnval:String = mdm.FileSystem.loadFile(thePathName)
        	return returnval;
        }
	}
}