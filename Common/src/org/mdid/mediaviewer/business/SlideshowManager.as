package org.mdid.mediaviewer.business
{
	import com.adobe.serialization.json.JSONDecoder;
	
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	
	import org.mdid.mediaviewer.events.*;
	import org.mdid.mediaviewer.vo.*;

	public class SlideshowManager
	{
		private var dispatcher:IEventDispatcher;
		private var cacheManager:CacheManager;
		private var _currentImage1:int = -1;
		private var _currentImage2:int = -1;
		private var _currentPanePosition:int = 1;
		private var _numImagePanes:uint = 1;
		private var _isPairwiseModeEnabled:Boolean = false;
		private var _isImageMetaObjectsDirtyFlag:Boolean = false;
		private var playTimer:Timer = new Timer(1000, 0);
		private var countdownTimer:Timer = new Timer(1000, 0);

		[Bindable] public var positionStatus:String; 
		[Bindable] public var timeUntilNext:String; 
		[Bindable] public var slideList:ArrayCollection = new ArrayCollection();
		[Bindable] public var catalogDataWindowTitle1:String = "N/A";
		[Bindable] public var catalogDataAsHtmlBlock1:String = "";
		[Bindable] public var notesDataAsHtmlBlock1:String = "";
		[Bindable] public var catalogDataWindowTitle2:String = "N/A";
		[Bindable] public var catalogDataAsHtmlBlock2:String = "";
		[Bindable] public var notesDataAsHtmlBlock2:String = "";
		[Bindable] public var serverURL:String;
		[Bindable] public var currentSlideshowID:String = "";
		
		
		public var maxCacheSizeMB:int;
		public var contentPath:String;
		public var slideshowTitle:String;
		
		public function get currentImage1():int {
			return _currentImage1;
		}
		public function get currentImage2():int {
			return _currentImage2;
		}
		public function get numSlides():int {
			return slideList.length;
		}

        public function SlideshowManager(dispatcher:IEventDispatcher, cacheManager:CacheManager) {
            this.dispatcher = dispatcher;
            this.cacheManager = cacheManager;
            this.playTimer.addEventListener(TimerEvent.TIMER, playNextSlide);
            this.countdownTimer.addEventListener(TimerEvent.TIMER, handleCountdown);
        }
		public function instantiateCacheManager():void {
			this.cacheManager.init(contentPath, serverURL, maxCacheSizeMB, this);
		}
		public function parseGetSlideshowInfoResults(result:Object):Object {
			var o:Object = {};
			o.isUserLoggedIn = result.userLoggedin;
			slideshowTitle = result.title;
			o.title = slideshowTitle;
			return(o);
		}
		public function unloadCurrentSlideshow(isLoggedOn:Boolean = false):void {
		 		this._currentImage1 = -1;
				this._currentImage2 = -1;
				this.cacheManager.cachingIndex = 0;
				this.cacheManager.thumbCachingIndex = 0;
				slideList.removeAll();
				currentSlideshowID = "";
				if (this._numImagePanes > 1) {
					var e:ControlBarClickEvent = new ControlBarClickEvent(ControlBarClickEvent.SINGLE_PANE);
					this.dispatcher.dispatchEvent(e);
				}
				this.catalogDataWindowTitle1 = "N/A";
				this.catalogDataAsHtmlBlock1 = "";
				this.notesDataAsHtmlBlock1 = "";
				this.catalogDataWindowTitle2 = "N/A";
				this.catalogDataAsHtmlBlock2 = "";
				this.notesDataAsHtmlBlock2 = "";
				//this.delayedRemoveImageTimer.start();
				var e1:SlideshowEvent = new SlideshowEvent(SlideshowEvent.REMOVE_IMAGES);
				this.dispatcher.dispatchEvent(e1);
				syncImageMetaObjects();
				if (!isLoggedOn) {
					var messageEvent:AppStatusEvent = new AppStatusEvent(AppStatusEvent.UPDATE_STATUS);
					messageEvent.message = "ALERT: Log into MDID again if you want to retrieve a slideshow.";
					dispatcher.dispatchEvent(messageEvent);
				}
		}

		public function parsePresentationResults(result:Object):void {
			var jd:JSONDecoder = new JSONDecoder(result.toString());
			var res:String = jd.getValue().result == null ? "" : jd.getValue().result;
			if (res.toLowerCase() != "ok") {
				//throw up error dialog box
				var myErrorMessage:AppStatusEvent = new AppStatusEvent(AppStatusEvent.UPDATE_STATUS);
				myErrorMessage.message = "ALERT: Unable to retrieve slideshow. Return to your MDID and try again.";
				dispatcher.dispatchEvent(myErrorMessage);
				return;
			}
			this.slideshowTitle = jd.getValue().title == null ? "" : jd.getValue().title;
			var myEvent:AppStatusEvent = new AppStatusEvent(AppStatusEvent.UPDATE_STATUS);
			myEvent.message = slideshowTitle;
			dispatcher.dispatchEvent(myEvent);
			if (GeneralFactory.getInstance().runmode == GeneralFactory.WEB_MODE) {
				mx.core.Application.application.pageTitle = this.slideshowTitle;
			}
			var content:Object = jd.getValue().content;
			for each (var item:Object in content) {
				var _imageResource:String = item.image != null ? item.image : "";
				var _thumbResource:String = item.thumbnail != null ? item.thumbnail : "";
				var _slideID:String = item.slideid != null ? item.slideid : "";
				var _imageID:String = item.id != null ? item.id : "";
				var _collectionID:String = item.collectionid != null ? item.collectionid : "";
				var _imageFilename:String = item.filename != null ? item.filename : "";
				var _slideAnnotation:String = item.slideannotation != null ? item.slideannotation : "";
				var _imageNotes:String = item.imagenotes != null ? item.imagenotes : "";
				var metadata:Object = item.metadata;
				var xml:XML = new XML(<fields/>);
				var i:uint = 0;
				for each (var thing:Object in metadata) {
					var label:String = thing.label != null ? thing.label : "";
					var value:String = thing.value != null ? thing.value : "";
					if (label.toLowerCase() != "identifier") {
						xml.appendChild(<field/>);
						xml.field[i].@name = label;
						xml.field[i] = value;
						i++;
					}
				}
				var _catalogData:XMLList = new XMLList(xml.field);
				var mySlide:Slide = new Slide(_imageResource, _slideID, _imageID, _collectionID, _imageFilename, _slideAnnotation, _imageNotes, _catalogData, _thumbResource);
				slideList.addItem(mySlide);
			}
			var myEvent2:AppStatusEvent = new AppStatusEvent(AppStatusEvent.UPDATE_STATUS);
			myEvent2.message = slideshowTitle;
			dispatcher.dispatchEvent(myEvent2);
			if (slideList.length > 0) {
				_currentImage1 = 0;
				_currentImage2 = 0;
				var loadComplete:SlideshowEvent = new SlideshowEvent(SlideshowEvent.SLIDESHOW_LOAD_COMPLETE);
				loadComplete.numSlides = slideList.length;
				dispatcher.dispatchEvent(loadComplete);
			}
			this.cacheManager.preCacheImages();
		}
		public function parseGetSlideshowResults(result:Object, slideshowID:String, title:String=""):Object {
            var success:Boolean = GeneralFactory.getInstance().runmode == GeneralFactory.AIR_MODE ? result.resultcode == "SUCCESS" : result != null;
			if (success) {
				if (GeneralFactory.getInstance().mdidversion == GeneralFactory.MDID2 && GeneralFactory.getInstance().runmode == GeneralFactory.AIR_MODE) {
					if (result.slides.length < 1 || (result.slides.length == 1 && result.slides[0].imageid == 0)) {
						result.resultcode = "ERROR";
						result.errormessage = "Selected slideshow is empty. Please select another.";
						return result;
					}
				}
				if (this.slideList.length > 0) { //a slideshow is already loaded...clear it
					unloadCurrentSlideshow(true);
				}
				this.currentSlideshowID = slideshowID;
				var slides:Object;
				switch (GeneralFactory.getInstance().runmode) {
					case GeneralFactory.AIR_MODE:
						slideshowTitle = title;
						slides = result.slides;
						break;
					case GeneralFactory.WEB_MODE:
						slideshowTitle = title;
						mx.core.Application.application.pageTitle = title;
						slides = result;
						break;
					case GeneralFactory.ZINC_MODE:
						slideshowTitle = result.SlideshowProperties.title;
						slides = result.Slides.children();
						break;
				}
				for each (var item:Object in slides){
					var _imageResource:String = item.imageresource != null ? item.imageresource : "";
					var _slideID:String = item.slideid != null ? item.slideid : "";
					var _imageID:String = item.imageid != null ? item.imageid : "";
					var _collectionID:String = item.collectionid != null ? item.collectionid : "";
					var _imageFilename:String = item.imagefilename != null ? item.imagefilename : "";
					var _slideAnnotation:String = item.slideannotation != null ? item.slideannotation : "";
					var _imageNotes:String = item.imagenotes != null ? item.imagenotes : "";
					var _catalogData:XMLList;
					if (GeneralFactory.getInstance().runmode == GeneralFactory.ZINC_MODE) {
						_imageFilename = _imageResource;
						_catalogData = new XMLList(item.catalogdata != null ? item.catalogdata.fields.children() : null);
					} else if (item.catalogdata != null) {
						var xml:XML = new XML(<fields/>);
						for(var i:uint = 0; i<item.catalogdata.fields.length; i++) {
							xml.appendChild(<field/>);
							xml.field[i].@name = item.catalogdata.fields[i].name;
							xml.field[i] = item.catalogdata.fields[i].value;
						}
						_catalogData = new XMLList(xml.field);
					}
					var mySlide:Slide = new Slide(_imageResource, _slideID, _imageID, _collectionID, _imageFilename, _slideAnnotation, _imageNotes, _catalogData);
					slideList.addItem(mySlide);
				}
				var myEvent:AppStatusEvent = new AppStatusEvent(AppStatusEvent.UPDATE_STATUS);
				myEvent.message = slideshowTitle;
				dispatcher.dispatchEvent(myEvent);
				if (slideList.length > 0) {
					_currentImage1 = 0;
					_currentImage2 = 0;
					var loadComplete:SlideshowEvent = new SlideshowEvent(SlideshowEvent.SLIDESHOW_LOAD_COMPLETE);
					loadComplete.numSlides = slideList.length;
					dispatcher.dispatchEvent(loadComplete);
				}
				this.cacheManager.preCacheImages();
			}
			return result;
		}
		public function parseSlideshowFromXmlFile(localPath:String):void {
			var xmlstr:String = GeneralFactory.getInstance().loadLocalXmlFile(localPath + Settings.ZINC_XML_SLIDESHOW_FILENAME);			
			var xml:XML = new XML(xmlstr);
			this.slideshowTitle = xml.child("SlideshowProperties").child("title").text();
			parseGetSlideshowResults(xml, "", slideshowTitle);
			return;
			var slides:Object = xml.child("Slides").children();
			for each(var item:Object in slides){
				var _imageResource:String = item.imageresource != null ? item.imageresource : "";
				var _catalogData:ArrayCollection = item.catalogdata.fields;// != null ? item.catalogdata.fields : null;
				var mySlide:Slide = new Slide(_imageResource, "", "", "", "", _catalogData);
				slideList.addItem(mySlide);
			}
			var myEvent:AppStatusEvent = new AppStatusEvent(AppStatusEvent.UPDATE_STATUS);
			myEvent.message = slideshowTitle;
			dispatcher.dispatchEvent(myEvent);
			if (slideList.length > 0) {
				_currentImage1 = 0;
				dispatchUpdateImageEvent(_currentImage1, SlideshowEvent.UPDATE_IMAGE_1);
			}
			this.cacheManager.preCacheImages();
		}
		private function dispatchUpdateImageEvent(idx:int, eType:String, doSyncFunctions:Boolean = true):void {
			if (this.slideList.length < 1) return;
			_isImageMetaObjectsDirtyFlag = true;
			var myUpdateEvent:SlideshowEvent = new SlideshowEvent(eType);
			try {
				myUpdateEvent.imageObject = cacheManager.getImageByURL(slideList[idx].imageFilename, slideList[idx].imageURL);
				myUpdateEvent.isImageValid = slideList[idx].imageIsValid;
				dispatcher.dispatchEvent(myUpdateEvent);
			} catch (e:Error) {
				trace(e.message);
			}
		}
		private function syncImageMetaObjects():void {
			calculateButtonStates();		
			setTopBarTitle();
			setCatalogData();
			_isImageMetaObjectsDirtyFlag = false;
		}
		public function invalidateAllImages():void {
			for each (var item:Object in this.slideList) {
				item.imageIsValid = false;
			}
			this.gotoSlideByIndex(this.currentImage1, 1);
			if (this._numImagePanes > 1) {
				this.gotoSlideByIndex(this.currentImage2, 2);
			}
		}
		public function calculateButtonStates():void {
			var myCalcButtonStatesEvent:AppStatusEvent = new AppStatusEvent(AppStatusEvent.CALC_BUTTON_STATES);
			myCalcButtonStatesEvent.curSlideIdx1 = _currentImage1;
			myCalcButtonStatesEvent.curSlideIdx2 = _currentImage2;
			myCalcButtonStatesEvent.numSlides = slideList.length;
			myCalcButtonStatesEvent.cachingIdx = this.cacheManager.cachingIndex;
			myCalcButtonStatesEvent.slideshowIsPlaying = playTimer.running;
			myCalcButtonStatesEvent.isPairwiseModeEnabled = this._isPairwiseModeEnabled;
			this.dispatcher.dispatchEvent(myCalcButtonStatesEvent);
		}
		public function setTopBarTitle():void {
			var myTopHeaderMessage:AppStatusEvent = new AppStatusEvent(AppStatusEvent.UPDATE_STATUS);
			if (this.slideList.length < 1) {
				//myTopHeaderMessage.message = "Please select a slideshow.";
			} else if (this._numImagePanes > 1 || _currentImage1 < 0 || _currentImage1 >= slideList.length) {
				myTopHeaderMessage.message = this.slideshowTitle;
			} else {
				myTopHeaderMessage.message = this.slideshowTitle + " » " + slideList[_currentImage1].title;
			}
			dispatcher.dispatchEvent(myTopHeaderMessage);
			setPositionStatus();
		}
		public function setPositionStatus():void {
			positionStatus = "";
			if (this._numImagePanes == 1) {
				if (_currentImage1 >= 0 && _currentImage1 < slideList.length) {
					positionStatus = (_currentImage1+1).toString() + " of " + slideList.length.toString();
				}
			} else if (this._numImagePanes == 2) {
				if (_currentImage1 >= 0 && _currentImage1 < slideList.length && _currentImage2 >= 0 && _currentImage2 < slideList.length) {
					positionStatus = (_currentImage1+1).toString() + ", " + (_currentImage2+1).toString() + " of " + slideList.length.toString();
				}
			}
		}
		public function setCatalogData():void {
			if (currentImage1 > -1 && currentImage1 < slideList.length) {
				this.catalogDataWindowTitle1 = (_currentImage1+1).toString() + "/" + slideList.length.toString();
				this.catalogDataAsHtmlBlock1 = slideList[_currentImage1].catalogDataAsHtmlBlock;
				this.notesDataAsHtmlBlock1 = slideList[_currentImage1].notesDataAsHtmlBlock;
			}
			if (this._numImagePanes > 1 && currentImage2 > -1 && currentImage2 < slideList.length) {
				this.catalogDataWindowTitle2 = (_currentImage2+1).toString() + "/" + slideList.length.toString();
				this.catalogDataAsHtmlBlock2 = slideList[_currentImage2].catalogDataAsHtmlBlock;
				this.notesDataAsHtmlBlock2 = slideList[_currentImage2].notesDataAsHtmlBlock;
			}			
		}
		public function gotoSlideByIndex(theIdx:int, thePanePosition:int = 1):void {
			if (this.slideList.length < 1) return;
			if (this._isPairwiseModeEnabled && theIdx > 0 && theIdx % 2) theIdx--;
			if (theIdx >= 0 && theIdx < slideList.length) {
				if (thePanePosition == 1) {
					_currentImage1 = theIdx;
					dispatchUpdateImageEvent(_currentImage1, SlideshowEvent.UPDATE_IMAGE_1);
					if (_currentImage1 + 1 >= slideList.length && playTimer.running) {
						stopPlayTimer();
					}
				} else if (!this._isPairwiseModeEnabled && thePanePosition == 2) {
					_currentImage2 = theIdx;
					dispatchUpdateImageEvent(_currentImage2, SlideshowEvent.UPDATE_IMAGE_2);
					if (_currentImage2 + 1 >= slideList.length && playTimer.running) {
						stopPlayTimer();
					}
				}
			}
			if (this._isPairwiseModeEnabled) {
				var newImage2Idx:int = _currentImage1 < slideList.length - 1 ? _currentImage1 + 1 : slideList.length -1;
				if (newImage2Idx != _currentImage2) {
					_currentImage2 = newImage2Idx;
					dispatchUpdateImageEvent(_currentImage2, SlideshowEvent.UPDATE_IMAGE_2);
				}
			}
			if (_isImageMetaObjectsDirtyFlag) syncImageMetaObjects();
		}
		public function gotoSlideByPane(gotoType:String, thePanePosition:int, shiftKeyDown:Boolean):void {
			if (this.slideList.length < 1) return;
			switch(gotoType) {
				case EdgeControlsEvent.NEXT_SLIDE:
					if (this._isPairwiseModeEnabled) {
						this.gotoSlide(shiftKeyDown ? ControlBarClickEvent.LAST_SLIDE : ControlBarClickEvent.NEXT_SLIDE, 1);
						return;
					}
					if (thePanePosition == 1 && _currentImage1 < slideList.length - 1) {
						if (shiftKeyDown) {
							_currentImage1 = slideList.length - 1;
						} else {
							_currentImage1++;
						}
						dispatchUpdateImageEvent(_currentImage1, SlideshowEvent.UPDATE_IMAGE_1);
					}
					if (thePanePosition == 2 && _currentImage2 < slideList.length - 1) {
						if (shiftKeyDown) {
							_currentImage2 = slideList.length - 1;
						} else {
							_currentImage2++;
						}
						dispatchUpdateImageEvent(_currentImage2, SlideshowEvent.UPDATE_IMAGE_2);
					}
				break;
				case EdgeControlsEvent.PREVIOUS_SLIDE:
					if (this._isPairwiseModeEnabled) {
						this.gotoSlide(shiftKeyDown ? ControlBarClickEvent.FIRST_SLIDE : ControlBarClickEvent.PREVIOUS_SLIDE, 1);
						return;
					}
					if (thePanePosition == 1 && _currentImage1 > 0) {
						if (shiftKeyDown) {
							_currentImage1 = 0;
						} else {
							_currentImage1--;
						}
						dispatchUpdateImageEvent(_currentImage1, SlideshowEvent.UPDATE_IMAGE_1);
					}
					if (thePanePosition == 2 && _currentImage2 > 0) {
						if (shiftKeyDown) {
							_currentImage2 = 0;
						} else {
							_currentImage2--;
						}
						dispatchUpdateImageEvent(_currentImage2, SlideshowEvent.UPDATE_IMAGE_2);
					}
				break;
			}
			if (_isImageMetaObjectsDirtyFlag) syncImageMetaObjects();
		} 
		public function gotoSlide(gotoType:String, thePanePosition:int):void {
			if (this.slideList.length < 1) return;
			switch(gotoType) {
				case ControlBarClickEvent.NEXT_SLIDE:
					if (thePanePosition == 1 && _currentImage1 < slideList.length - 1) {
						_currentImage1++;
						if (this._isPairwiseModeEnabled && _currentImage1 < slideList.length - 1) {
							_currentImage1++;
						}
						dispatchUpdateImageEvent(_currentImage1, SlideshowEvent.UPDATE_IMAGE_1);
					}
					if (!this._isPairwiseModeEnabled && thePanePosition == 2 && _currentImage2 < slideList.length - 1) {
						_currentImage2++;
						dispatchUpdateImageEvent(_currentImage2, SlideshowEvent.UPDATE_IMAGE_2);
					}
				break;
				case ControlBarClickEvent.PREVIOUS_SLIDE:
					if (thePanePosition == 1 && _currentImage1 > 0) {
						_currentImage1--;
						if (this._isPairwiseModeEnabled && _currentImage1 > 0) {
							_currentImage1--;
						}
						dispatchUpdateImageEvent(_currentImage1, SlideshowEvent.UPDATE_IMAGE_1);
					}
					if (!this._isPairwiseModeEnabled && thePanePosition == 2 && _currentImage2 > 0) {
						_currentImage2--;
						dispatchUpdateImageEvent(_currentImage2, SlideshowEvent.UPDATE_IMAGE_2);
					}
				break;
				case ControlBarClickEvent.LAST_SLIDE:
					if (thePanePosition == 1 && _currentImage1 != slideList.length - 1 ) {
						_currentImage1 = (this._isPairwiseModeEnabled && slideList.length % 2 == 0) ? slideList.length - 2 : slideList.length - 1;
						dispatchUpdateImageEvent(_currentImage1, SlideshowEvent.UPDATE_IMAGE_1);
					}
					if (!this._isPairwiseModeEnabled && thePanePosition == 2 && _currentImage2 != slideList.length - 1 ) {
						_currentImage2 = slideList.length - 1;
						dispatchUpdateImageEvent(_currentImage2, SlideshowEvent.UPDATE_IMAGE_2);
					}
				break;
				case ControlBarClickEvent.FIRST_SLIDE:
					if (thePanePosition == 1 && _currentImage1 != 0) {
						_currentImage1 = 0;
						dispatchUpdateImageEvent(_currentImage1, SlideshowEvent.UPDATE_IMAGE_1);
					}
					if (!this._isPairwiseModeEnabled && thePanePosition == 2 && _currentImage2 != 0) {
						_currentImage2 = 0;
						dispatchUpdateImageEvent(_currentImage2, SlideshowEvent.UPDATE_IMAGE_2);
					}
				break;
				case SlideshowEvent.REFRESH_CURRENT_IMAGE:
					if (thePanePosition < 2 && _currentImage1 >=0 && _currentImage1 < slideList.length) {
						dispatchUpdateImageEvent(_currentImage1, SlideshowEvent.UPDATE_IMAGE_1);
					}
					if (!this._isPairwiseModeEnabled && (thePanePosition == 2 || thePanePosition < 0)) {
						if (_currentImage2 < 0) {
							_currentImage2 = _currentImage1;
						}
						if (_currentImage2 >=0 && _currentImage2 < slideList.length) {
							dispatchUpdateImageEvent(_currentImage2, SlideshowEvent.UPDATE_IMAGE_2);
						}
					}
				break;
			}
			if (this._isPairwiseModeEnabled) {
				var newImage2Idx:int = _currentImage1 < slideList.length - 1 ? _currentImage1 + 1 : slideList.length -1;
				if (gotoType == SlideshowEvent.REFRESH_CURRENT_IMAGE || newImage2Idx != _currentImage2) {
					_currentImage2 = newImage2Idx;
					dispatchUpdateImageEvent(_currentImage2, SlideshowEvent.UPDATE_IMAGE_2);
				}
			}
			if (thePanePosition == 1 && _currentImage1 + 1 >= slideList.length && playTimer.running) {
				stopPlayTimer();
			}
			if (thePanePosition == 2 && _currentImage2 + 1 >= slideList.length && playTimer.running) {
				stopPlayTimer();
			}
			if (_isImageMetaObjectsDirtyFlag) syncImageMetaObjects();
		}
		private function stopPlayTimer():void {
			playTimer.reset();
			countdownTimer.reset();
			calculateButtonStates();
		}
		private function playNextSlide(e:TimerEvent):void {
			if (this._currentPanePosition == 1) {
				if (_currentImage1 + 2 >= numSlides) {
					stopPlayTimer();
				}
				if (_currentImage1 < numSlides) {
					if (this._isPairwiseModeEnabled && _currentImage1 + 1 < numSlides) {
						this.gotoSlideByIndex(_currentImage1 + 2, _currentPanePosition);
					} else {
						this.gotoSlideByIndex(_currentImage1 + 1, _currentPanePosition);
					}
					
					countdownTimer.reset();
					countdownTimer.start();
					setTimeUntilNext(playTimer.delay/1000);
				}
			} else if (this._currentPanePosition == 2) {
				if (_currentImage2 + 2 >= numSlides) {
					stopPlayTimer();
				}
				if (_currentImage2 < numSlides) {
					this.gotoSlideByIndex(_currentImage2 + 1, _currentPanePosition);
					countdownTimer.reset();
					countdownTimer.start();
					setTimeUntilNext(playTimer.delay/1000);
				}
			}
		}
		private function setTimeUntilNext(theSeconds:int):void {
			var secs:String = (theSeconds %60).toString();
			var mins:String = (Math.floor(theSeconds/60)).toString();
			timeUntilNext = "Next in: " + mins + "m " + secs + "s";			
		}
		private function handleCountdown(e:TimerEvent):void {
			setTimeUntilNext(playTimer.delay/1000 - countdownTimer.currentCount);
		}

		public function startStopSlideshow(eventType:String, seconds:int, thePanePosition:int):void {
			countdownTimer.reset();
			playTimer.reset();
			if (eventType == ControlBarClickEvent.START_SHOW) {
				playTimer.delay = seconds * 1000;
				this._currentPanePosition = thePanePosition;
				playTimer.start();
				countdownTimer.start();
				setTimeUntilNext(playTimer.delay/1000);
			}
			calculateButtonStates();
		}
		public function checkCacheSize():void {
			cacheManager.checkCacheSize();
		}
		public function setNumImagePanes(theNum:uint):void {
			this._numImagePanes = theNum;
		}
		public function togglePairwiseMode(theEnablePairwiseMode:Boolean):void {
			this._isPairwiseModeEnabled = theEnablePairwiseMode && this.numSlides > 3;
			if (this._isPairwiseModeEnabled) {
				if (_currentImage1 > 0 && _currentImage1 % 2) {
					this.gotoSlideByIndex(_currentImage1-1, 1);
					//this.gotoSlide(SlideshowEvent.REFRESH_CURRENT_IMAGE, -1);
				} else {
					this.gotoSlide(SlideshowEvent.REFRESH_CURRENT_IMAGE, 2);
				}
			}
		}
		public function handleGetSlideshowFault(fault:Object):Object {
			trace(fault);
			return fault;
		}
	}
}