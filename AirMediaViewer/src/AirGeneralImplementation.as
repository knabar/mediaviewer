package
{
	import flash.display.StageDisplayState;
	import flash.events.FileListEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	
	import mx.controls.*;
	import mx.core.Application;
	
	public class AirGeneralImplementation implements IGeneral
	{
		private var _mdidversion:String = "";
		private var _keepaliveurl:String = "";
		private var _returntourl:String = "";
		private var _contentPath:String = "";
		private var _thumbPath:String = "";
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
			return File.separator;
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
			return GeneralFactory.AIR_MODE;	
		}
		public function flashVarItem(theKey:String):String {
			throw new Error("This functionality isn't supported in the AIR version (flashVarItem).");
		}
		public function queryStringItem(theKey:String):String {
			//AIR app does not have a URL with QueryString
			throw new Error("This functionality isn't supported in the AIR version (queryStringItem).");	
		}
		public function ensureFolderExists(thePath:String):void {
			var temp:File = new File(thePath);
			if (!temp.isDirectory) {
				try {
					temp.createDirectory();
				} catch(e:Error) {
					throw(e);
				}
			}
		}
		public function fileExists(thePathName:String):Boolean {
			var temp:File = new File(thePathName);
			return (temp.exists && !temp.isDirectory);
		}
		public function ensureFolderSizeUnderMax(maxCacheKB:int):void {
			var dir:File = new File(this._contentPath);
			//maxCacheKB = 1000*1024;
			if (dir.exists && dir.isDirectory) {
				dir.addEventListener(FileListEvent.DIRECTORY_LISTING, directoryListingHandler);
				dir.getDirectoryListingAsync();
			}
			
			function directoryListingHandler(event:FileListEvent):void {
			    var list:Array = event.files;
			    var dirSizeBytes:uint = list.length * 4096; //est. size of thumbnails folder
			    for (var i:uint = 0; i < list.length; i++) {
			        if (!list[i].isDirectory) {
			        	dirSizeBytes += list[i].size;
			        }
			    }
		        if (dirSizeBytes/1024 > maxCacheKB * .95) {
		        	list.sortOn("modificationDate", Array.NUMERIC);
		        	for (var j:uint = 0; j < list.length; j++) {
		        		//trace(list[j].modificationDate + " (" + list[j].name + ")");
		        		if (!list[j].isDirectory) {
		        			dirSizeBytes -= list[j].size;
		        			var filename:String = list[j].name;
		        			var thumbname:String = filename.substr(0, filename.lastIndexOf(".")) + "_thumb" + filename.substring(filename.lastIndexOf("."));
		        			var thumb:File = new File(GeneralFactory.getInstance().getLocalThumbCachePath() + thumbname);
		        			if (thumb.exists && !thumb.isDirectory) {
		        				thumb.deleteFileAsync();
		        				dirSizeBytes -= 4096;
		        			}
		        			list[j].deleteFileAsync();
		        		}
		        		if (dirSizeBytes/1024 <= maxCacheKB * .9) break;
		        	}
		        }
}			//check size of directory, delete oldest files first until cache is 90% of max or less
		}
		public function writeBinaryFileToCache(theLoader:URLLoader, thePathName:String):void {
			var file:File = new File(thePathName);
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeBytes(theLoader.data)
			stream.close();
		}
		public function getDocumentsDirectory():String {
			var f:File = File.documentsDirectory;
			return f.nativePath + File.separator;
		}
		public function setLocalCachePath(thePath:String):Boolean {
			try {
				var temp:File = new File(thePath);
				if (temp.exists && !temp.isDirectory) {
					throw(new Error());
				}
				if (!temp.isDirectory) {
					temp.createDirectory();
				}
				this._contentPath = temp.nativePath + File.separator;
				var temp2:File = new File(this._contentPath + "thumbnails");
				if (temp2.exists && !temp2.isDirectory) {
					throw(new Error());
				}
				if (!temp2.isDirectory) {
					temp2.createDirectory();
				}
				this._thumbPath = temp2.nativePath + File.separator;			
			} catch(e:Error) {
				return false;
			}
			return (this._contentPath.length > 2);
		}
		public function getLocalCachePath():String {
			return this._contentPath;
		}
		public function getLocalThumbCachePath():String {
			return this._thumbPath;
		}
		public function getLocalAppDirectory():String {
			var f:File = File.applicationDirectory;
			return f.nativePath + File.separator;
		}
		public function getPrefsFile():String {
			var prefsLocation:String = GeneralFactory.getInstance().mdidversion == GeneralFactory.MDID2 ? Settings.PREFS_LOCATION_MDID2 : Settings.PREFS_LOCATION_MDID3;
			//var prefPath:String = File.applicationDirectory + prefsLocation;
			trace(prefsLocation);
			var file:File = File.applicationStorageDirectory; //File.applicationDirectory;
			file = file.resolvePath(prefsLocation);
			if (!file.exists) {
				file = File.applicationDirectory;
				file = file.resolvePath(prefsLocation);
				//if no file there, create one.
			}
			trace(file.nativePath);
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			var str:String = stream.readMultiByte(file.size, File.systemCharset);
			stream.close();
			return str;
		}
		public function jumpToUrl(theUrl:String, target:String="_self"):void {
			throw new Error("This functionality isn't supported in the AIR version (jumpToUrl).");
		}
        public function toggleFullScreen():void {
             switch(Application.application.stage.displayState) {
                case StageDisplayState.FULL_SCREEN:
                case StageDisplayState.FULL_SCREEN_INTERACTIVE:
                    Application.application.stage.displayState = StageDisplayState.NORMAL;    
                    break;
                case StageDisplayState.NORMAL:
                default:
                    Application.application.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;    
                    break;
            }
        }
        public function loadLocalXmlFile(thePathName:String):String {
        	var file:File = new File(thePathName);
        	var stream:FileStream = new FileStream();
        	stream.open(file, FileMode.READ);
        	var str:String = stream.readMultiByte(file.size, File.systemCharset);
        	return str;
        }
	}
}