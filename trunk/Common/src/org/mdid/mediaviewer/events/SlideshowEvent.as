package org.mdid.mediaviewer.events
{
	import flash.events.Event;
	
	public class SlideshowEvent extends Event
	{
		public static const GET_HTTP:String = "getHttpEvent";
		public static const GET_HTTPS:String = "getHttpsEvent";
		public static const GET_FROM_QUERYSTRING:String = "getFromQueryStringEvent";
		public static const GET_FROM_FLASHVAR:String = "getFromFlashVarEvent";
		public static const GET_FROM_LOCAL_XML_FILE:String = "getFromLocalXmlFileEvent";
		public static const GET_SLIDESHOW_INFO_MDID2:String = "getSlideshowInfoMdid2Event";
		public static const GET_PRESENTATION_MDID3:String = "getPresentationMdid3Event";
		public static const UPDATE_IMAGE_1:String = "updateImage1Event";
		public static const UPDATE_IMAGE_2:String = "updateImage2Event";
		public static const UPDATE_IMAGE_3:String = "updateImage3Event";
		public static const IMAGE_CACHING_COMPLETE:String = "imageCachingCompleteEvent";
		public static const CHECK_CACHE_SIZE:String = "checkCacheSizeEvent";
		public static const REFRESH_CURRENT_IMAGE:String = "refreshCurrentImageEvent";
		public static const REFRESH_CURRENT_IMAGES_1_2:String = "refreshCurrentImage1AndImage2Event";
		public static const REFRESH_TOPBAR_TITLE:String = "refreshTopBarTitleEvent";
		public static const SET_NUM_IMAGE_PANES:String = "setNumImagePanesEvent";
		public static const UNLOAD_CURRENT_SLIDESHOW:String = "unloadCurrentSlideshowEvent";
		public static const SLIDESHOW_LOAD_COMPLETE:String = "slideshowLoadCompleteEvent";
		public static const SHOW_CATALOG_DATA:String = "showCatalogDataEvent";
		public static const SHOW_CATALOG_DATA_1:String = "showCatalogData1Event";
		public static const SHOW_CATALOG_DATA_2:String = "showCatalogData2Event";
		public static const REMOVE_IMAGES:String = "removeImagesEvent";
		
		public var imageObject:Object;
		public var slideshowID:String = "";
		public var isImageValid:Boolean;
		public var presentationUrl:String;
		public var sessiontoken:String;
		public var slideshowtitle:String;
		public var cachedFileName:String;
		public var numImagePanes:uint = 0;
		public var panePosition:int;
		public var numSlides:int = 0;
		public var isDispatchedFromTopBar:Boolean = true;

		public function SlideshowEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			//super(type, false, true);
		}

	}
}