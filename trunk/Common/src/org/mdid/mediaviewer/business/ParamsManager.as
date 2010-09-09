package org.mdid.mediaviewer.business
{
	import flash.events.IEventDispatcher;
	import mx.core.Application;
	import mx.utils.URLUtil;
	import org.mdid.mediaviewer.events.AppStatusEvent;

	public class ParamsManager
	{
		private var dispatcher:IEventDispatcher;
		
		[Bindable] public var serverUrl:String;
		public var secureServerUrl:String;
		public var institution:String;
		public var welcomeMessage:String = "Welcome";
		public var localCachePath:String;
		public var localApplicationPath:String;
		public var maxCacheSizeMbytes:Number = Settings.DEFAULT_CACHE_MBYTES;

		public function ParamsManager(dispatcher:IEventDispatcher):void {
			this.dispatcher = dispatcher;
		}
		private function _parseMDID2XML(xml:XML):void {
			var xmlns:Namespace = new Namespace("http://mdid.jmu.edu/imageviewer");
			var url:String = xml..xmlns::url;
			var cacheFolderName:String = xml..xmlns::localcache;
			var maxMbytes:String = xml..xmlns::localcache.@maxsize;
			if (!isNaN(parseFloat(maxMbytes))) {
				maxCacheSizeMbytes = parseFloat(maxMbytes);
				if (maxCacheSizeMbytes < Settings.MIN_CACHE_MBYTES) {
					maxCacheSizeMbytes = Settings.MIN_CACHE_MBYTES;
				}
			}
			if (GeneralFactory.getInstance().setLocalCachePath(GeneralFactory.getInstance().getDocumentsDirectory() + cacheFolderName)) {
				localCachePath = GeneralFactory.getInstance().getLocalCachePath();
			}
			serverUrl = URLUtil.replaceProtocol(url,"http");
			secureServerUrl = URLUtil.replaceProtocol(url, "https");
			var myContactServerEvent:AppStatusEvent = new AppStatusEvent(AppStatusEvent.CONTACT_SERVER);
			dispatcher.dispatchEvent(myContactServerEvent);
		}
		private function _parseMDID3XML(xml:XML):void {
			_parseMDID2XML(xml);
		}
		public function parseXml(xml:XML):void {
			switch(GeneralFactory.getInstance().mdidversion) {
				case GeneralFactory.MDID2:
					if (GeneralFactory.getInstance().runmode == GeneralFactory.AIR_MODE) {
						_parseMDID2XML(xml);
					}
					break;
				case GeneralFactory.MDID3:
					_parseMDID3XML(xml);
					break;
			}
			var myPrefsFileLoadCompleteEvent:AppStatusEvent = new AppStatusEvent(AppStatusEvent.PREFS_FILE_LOAD_COMPLETE);
			dispatcher.dispatchEvent(myPrefsFileLoadCompleteEvent);
		}
		public function loadPrefs():void {
			var myLoadPrefsFileEvent:AppStatusEvent = new AppStatusEvent(AppStatusEvent.LOAD_PREFS_FILE);
			switch (GeneralFactory.getInstance().runmode) {
				case GeneralFactory.AIR_MODE:
					var text:String = GeneralFactory.getInstance().getPrefsFile();
					parseXml(new XML(text));
				break;
				case GeneralFactory.ZINC_MODE:
					//localCachePath = GeneralFactory.getInstance().setLocalCachePath("images");
					localApplicationPath = GeneralFactory.getInstance().getLocalAppDirectory();
					localCachePath = localApplicationPath;
					dispatcher.dispatchEvent(myLoadPrefsFileEvent);
					break;
				case GeneralFactory.WEB_MODE:
					//var browserManager:IBrowserManager = BrowserManager.getInstance();
					//browserManager.init();
					//browserManager.setTitle("MediaViewer");
					//var s:String = browserManager.url;
					var s:String = Application.application.url;
					if (GeneralFactory.getInstance().mdidversion == GeneralFactory.MDID2) {
						serverUrl = s.substring(0, s.lastIndexOf("" + Settings.MEDIAVIEWER_WEB_DIR_MDID2 + "/"));// + "/";
					} else {
						serverUrl = "";// s.substring(0, s.lastIndexOf("" + Settings.MEDIAVIEWER_WEB_DIR_MDID3 + "/"));
					}
					//trace(serverUrl);
					//dispatcher.dispatchEvent(myLoadPrefsFileEvent);
					var myValidateSessionEvent:AppStatusEvent = new AppStatusEvent(GeneralFactory.getInstance().mdidversion == GeneralFactory.MDID2 ? AppStatusEvent.VALIDATE_MDID2_SESSION : AppStatusEvent.VALIDATE_MDID3_SESSION);
					dispatcher.dispatchEvent(myValidateSessionEvent);
				break;
			}
		}
	}
}