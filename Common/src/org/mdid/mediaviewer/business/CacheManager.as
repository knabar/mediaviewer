package org.mdid.mediaviewer.business {

	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.Timer;
	
	import mx.events.IndexChangedEvent;
	
	import org.mdid.mediaviewer.events.AppStatusEvent;
	import org.mdid.mediaviewer.events.ControlBarClickEvent;
	import org.mdid.mediaviewer.events.SlideshowEvent;
   
    public class CacheManager
    {
		private var dispatcher:IEventDispatcher;
        private var contentPath:String;
        private var _serverURL:String;
        private var maxCacheSizeMB:int = -1;
		private var slideshowManager:SlideshowManager;
		private var _cachingIndex:int = 0;
		private var _thumbCachingIndex:int = 0;
		private var cacheDelayTimer:Timer = new Timer(300, 1);
		private var loadFirstDelayTimer:Timer = new Timer(200, 1);
		[Bindable] public var numImagesCached:Number = 0;
		[Bindable] public var numImagesCachedAsInteger:int = 0;
		
		public function get cachingIndex():int {
			return _cachingIndex;
		}
		public function set cachingIndex(val:int):void {
			_cachingIndex = val;
		}
		public function get thumbCachingIndex():int {
			return _thumbCachingIndex;
		}
		public function set thumbCachingIndex(val:int):void {
			_thumbCachingIndex = val;
		}
		public function get serverURL():String {
			return _serverURL;
		}
		public function CacheManager(dispatcher:IEventDispatcher):void {
			this.dispatcher = dispatcher;
			cacheDelayTimer.addEventListener(TimerEvent.TIMER, cacheNextImage);
			loadFirstDelayTimer.addEventListener(TimerEvent.TIMER, loadFirstImage);
		}
		public function init(contentPath:String, _serverURL:String, maxCacheSizeMB:int, slideshowManager:SlideshowManager):void {
			this.contentPath = contentPath;
			this._serverURL = _serverURL;
			this.maxCacheSizeMB = maxCacheSizeMB;
			this.slideshowManager = slideshowManager;
			if (GeneralFactory.getInstance().runmode == GeneralFactory.WEB_MODE) {
				var myEvent1:AppStatusEvent = new AppStatusEvent(AppStatusEvent.UPDATE_STATUS);
				myEvent1.message = "Retrieving slideshow...please wait.";
				dispatcher.dispatchEvent(myEvent1);
			}
		}
		public function getImageByURL(filename:String, getImageRes:String):Object {
			var iObject:Object = new Object();
			iObject.filename = filename;
			iObject.errmsg = "";
			iObject.success = true;
			iObject.cachingImage = false;
			switch (GeneralFactory.getInstance().runmode) {
				case GeneralFactory.WEB_MODE :
					iObject.url = _serverURL + getImageRes;
					break;
				case GeneralFactory.AIR_MODE :
					if (GeneralFactory.getInstance().fileExists(GeneralFactory.getInstance().getLocalCachePath() + filename)) {
						iObject.url = GeneralFactory.getInstance().getLocalCachePath()  + filename;
					} else {
						iObject.cachingImage = true;
						iObject.url = contentPath + filename;
						//addImageToCache(filename, _serverURL + getImageRes);
					}
					break;
				case GeneralFactory.ZINC_MODE :
					if (GeneralFactory.getInstance().fileExists(contentPath + filename)) {
						iObject.url = contentPath + filename;
					} else {
						iObject.errmsg = "Image missing from package.";
						iObject.success = false;
						iObject.url = "";
					}
					break;
			}
			return iObject;
		}
		public function checkCacheSize():void {
			//Only cacheing files when running in AIR
			//if max cache size unknown, let it grow
			if (GeneralFactory.getInstance().runmode == GeneralFactory.AIR_MODE && this.maxCacheSizeMB > 0) {
				GeneralFactory.getInstance().ensureFolderSizeUnderMax(this.maxCacheSizeMB * 1024);
			}
		}
		private function getImageURL(theIdx:int):String {
			if (theIdx < 0 || theIdx >= slideshowManager.slideList.length) return "";
			switch (GeneralFactory.getInstance().runmode) {
				case GeneralFactory.WEB_MODE :
				case GeneralFactory.AIR_MODE :
					return _serverURL + slideshowManager.slideList[_cachingIndex].imageURL;
					break;
				case GeneralFactory.ZINC_MODE :
					return contentPath + slideshowManager.slideList[_cachingIndex].imageFilename;
					break;
				default:
					return "";
					break;
			}
		}
		private function getThumbURL(theIdx:int):String {
				if (theIdx < 0 || theIdx >= slideshowManager.slideList.length) return "";
				switch (GeneralFactory.getInstance().runmode) {
					case GeneralFactory.WEB_MODE :
					case GeneralFactory.AIR_MODE :
						return _serverURL + slideshowManager.slideList[_cachingIndex].thumbURL;
						break;
					case GeneralFactory.ZINC_MODE :
						//return contentPath + slideshowManager.slideList[_cachingIndex].imageFilename;
						//break;
					default:
						return "";
						break;
				}
		}
		private function getImageLocalPath(theIdx:int):String {
				if (theIdx < 0 || theIdx >= slideshowManager.slideList.length) return "";
				switch (GeneralFactory.getInstance().runmode) {
					case GeneralFactory.WEB_MODE :
						return "";
						break;
					case GeneralFactory.AIR_MODE :
					case GeneralFactory.ZINC_MODE :
						return GeneralFactory.getInstance().getLocalCachePath() + slideshowManager.slideList[_cachingIndex].imageFilename;
						break;
					default:
						return "";
						break;
				}
		}
		private function getThumbLocalPath(theIdx:int):String {
				if (theIdx < 0 || theIdx >= slideshowManager.slideList.length) return "";
				switch (GeneralFactory.getInstance().runmode) {
					case GeneralFactory.WEB_MODE :
						return "";
						break;
					case GeneralFactory.AIR_MODE :
						return GeneralFactory.getInstance().getLocalThumbCachePath() + slideshowManager.slideList[_cachingIndex].thumbFilename;
						break;
					case GeneralFactory.ZINC_MODE :
						return "";//contentPath + slideshowManager.slideList[_cachingIndex].imageFilename;
						break;
					default:
						return "";
						break;
				}
		}
		private function cacheNextImage(e:Event):void {
			this.cacheDelayTimer.stop();
			this.cacheDelayTimer.reset();
			preCacheImages();
		}
		public function preCacheImages():void {
			if (this._cachingIndex >= slideshowManager.slideList.length) {
				if (GeneralFactory.getInstance().runmode == GeneralFactory.AIR_MODE) {		
					var myCheckCacheSize:SlideshowEvent = new SlideshowEvent(SlideshowEvent.CHECK_CACHE_SIZE);
					dispatcher.dispatchEvent(myCheckCacheSize);
				}
				return;
			}
			if (GeneralFactory.getInstance().runmode == GeneralFactory.WEB_MODE) {
				var webThumbReq:URLRequest = new URLRequest(getThumbURL(_cachingIndex));
				webThumbReq.method = URLRequestMethod.GET;
				var webThumbLoader:URLLoader = new URLLoader();
				webThumbLoader.addEventListener(IOErrorEvent.IO_ERROR, handleBrokenThumb);
				webThumbLoader.load(webThumbReq);
				var webModeImageReq:URLRequest = new URLRequest(getImageURL(_cachingIndex));
				webModeImageReq.method = URLRequestMethod.GET;
				var webModeImageLoader:URLLoader = new URLLoader();
				webModeImageLoader.addEventListener(Event.COMPLETE, imageLoadComplete);
				webModeImageLoader.addEventListener(IOErrorEvent.IO_ERROR, handleBrokenImage);
				webModeImageLoader.addEventListener(ProgressEvent.PROGRESS, updateCacheStatus);
				webModeImageLoader.load(webModeImageReq);
			} else if (GeneralFactory.getInstance().runmode == GeneralFactory.AIR_MODE) {
				var path:String = this.getImageLocalPath(_cachingIndex);
				var thumbPath:String = this.getThumbLocalPath(_thumbCachingIndex);
				if (!GeneralFactory.getInstance().fileExists(thumbPath)) {
					var thumbReq:URLRequest = new URLRequest(getThumbURL(_thumbCachingIndex));
					thumbReq.method = URLRequestMethod.GET;
					var thumbLoader:URLLoader = new URLLoader();
					thumbLoader.addEventListener(Event.COMPLETE, addThumbToCache);
					thumbLoader.addEventListener(IOErrorEvent.IO_ERROR, handleBrokenThumb);
					thumbLoader.dataFormat = URLLoaderDataFormat.BINARY;
					thumbLoader.load(thumbReq);
				} else {
					_thumbCachingIndex++;
				}
				if (GeneralFactory.getInstance().fileExists(path)) {
					numImagesCached = _cachingIndex+1;
					imageLoadComplete(null, true);
				} else {
					var url:String = getImageURL(_cachingIndex);
					var req:URLRequest = new URLRequest(url);
					var loader:URLLoader = new URLLoader();
					loader.addEventListener(Event.COMPLETE, imageLoadComplete);
					loader.addEventListener(IOErrorEvent.IO_ERROR, handleBrokenImage);
					loader.addEventListener(ProgressEvent.PROGRESS, updateCacheStatus);
					loader.dataFormat = URLLoaderDataFormat.BINARY;
					loader.load(req);
				}
			}
		}
		private function handleBrokenThumb(e:IOErrorEvent):void {
			trace(e.text);
		}
		private function handleBrokenImage(e:IOErrorEvent):void {
			trace("broken image");
			imageLoadComplete(null, false);
		}
		private function updateCacheStatus(e:ProgressEvent):void {
			numImagesCached = _cachingIndex + (e.bytesTotal > 0 ? (e.bytesLoaded / e.bytesTotal) : 1);
		}
		private function loadFirstImage(e:Event=null):void {
			var myControlBarSimulationEvent:ControlBarClickEvent = new ControlBarClickEvent(ControlBarClickEvent.GO_TO_SLIDE);
			myControlBarSimulationEvent.panePosition = 1;
			myControlBarSimulationEvent.slideIdx = 0;
			dispatcher.dispatchEvent(myControlBarSimulationEvent);
		}
		private function addThumbToCache(e:Event):void {
			if (GeneralFactory.getInstance().runmode == GeneralFactory.AIR_MODE && e != null && slideshowManager.slideList[_thumbCachingIndex].thumbFilename != "_thumb") {
				GeneralFactory.getInstance().writeBinaryFileToCache(e.currentTarget as URLLoader, GeneralFactory.getInstance().getLocalThumbCachePath() + slideshowManager.slideList[_thumbCachingIndex].thumbFilename);
			}
			_thumbCachingIndex++;
		}
		private function imageLoadComplete(e:Event=null, isValidImage:Boolean=true):void {
			slideshowManager.slideList[_cachingIndex].imageIsValid = isValidImage;
			if (GeneralFactory.getInstance().runmode == GeneralFactory.AIR_MODE && isValidImage && e != null) {
				if (slideshowManager.slideList[_cachingIndex].imageFilename.length > 3) {
					GeneralFactory.getInstance().writeBinaryFileToCache(e.currentTarget as URLLoader, GeneralFactory.getInstance().getLocalCachePath() + slideshowManager.slideList[_cachingIndex].imageFilename);
					slideshowManager.slideList[_cachingIndex].imageIsCached = true;
				} else {
					slideshowManager.slideList[_cachingIndex].imageIsValid = false;
					slideshowManager.slideList[_cachingIndex].imageIsCached = false;
				}
			} else {
				slideshowManager.slideList[_cachingIndex].imageIsCached = true;
			}
			if (_cachingIndex == 0) { //Load first slide
				this.loadFirstDelayTimer.start();
			}
			_cachingIndex++;
			var myCalcButtonStatesEvent:AppStatusEvent = new AppStatusEvent(AppStatusEvent.CALC_BUTTON_STATES);
			myCalcButtonStatesEvent.curSlideIdx1 = slideshowManager.currentImage1;
			myCalcButtonStatesEvent.curSlideIdx2 = slideshowManager.currentImage2;
			myCalcButtonStatesEvent.numSlides = slideshowManager.slideList.length;
			myCalcButtonStatesEvent.cachingIdx = _cachingIndex;
			dispatcher.dispatchEvent(myCalcButtonStatesEvent);
			cacheDelayTimer.start();
		}
/*		private function imageLoadComplete(e:Event):void {
			var bytes:ByteArray = URLLoader(e.target).data;
			var loader:Loader = new Loader();
			numImagesCachedAsInteger = _cachingIndex + 1;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderComplete);
			loader.loadBytes(bytes);
		}
*/
/*		private function loaderComplete(e:Event):void {
			var bmd:BitmapData = (e.target.content as Bitmap).bitmapData;
			if (bmd != null && bmd.width > 0) {
				slideshowManager.slideList[_cachingIndex].imageIsCached = true;
				var m:Matrix = new Matrix();
				var newW:int = 100;
				var newH:int = 100;
				if (bmd.width > bmd.height) {
					newH = 100 * (bmd.height/bmd.width);
				} else {
					newW = 100 * (bmd.width/bmd.height);
				}
				m.scale(newW/bmd.width, newH/bmd.height);
				var newBmd:BitmapData = new BitmapData(newW, newH, false, 0x000000);
				newBmd.draw(bmd, m, null, null, null, true);
				slideshowManager.slideList[_cachingIndex].thumbBitmap = newBmd.clone();
				newBmd.dispose();
				bmd.dispose();
			}
			if (_cachingIndex == 0) { //Load first slide
				loadFirstImage();
			}
			_cachingIndex++;
			var myCalcButtonStatesEvent:AppStatusEvent = new AppStatusEvent(AppStatusEvent.CALC_BUTTON_STATES);
			myCalcButtonStatesEvent.curSlideIdx1 = slideshowManager.currentImage1;
			myCalcButtonStatesEvent.curSlideIdx2 = slideshowManager.currentImage2;
			myCalcButtonStatesEvent.numSlides = slideshowManager.slideList.length;
			myCalcButtonStatesEvent.cachingIdx = _cachingIndex;
			dispatcher.dispatchEvent(myCalcButtonStatesEvent);
			cacheDelayTimer.start();
		}
*/
	}
}