package org.mdid.mediaviewer.events
{
	import flash.events.Event;

	public class EdgeControlsEvent extends Event {
		public static const PIN_ZOOMPANTOOLBAR:String = "pinZoomPanToolBarEvent";
		public static const UNPIN_ZOOMPANTOOLBAR:String = "unpinZoomPanToolBarEvent";
		public static const ROLLOVER_ZOOMPANTOOLBAR:String = "rollOverZoomPanToolBarEvent";
		public static const ZOOMOUT:String = "zoomOutFromEdgeControlEvent";
		public static const ZOOMIN:String = "zoomInFromEdgeControlEvent";
		public static const NEXT_SLIDE:String = "advanceToNextSlideFromEdgeControlEvent";
		public static const PREVIOUS_SLIDE:String = "advanceToPreviousSlideFromEdgeControlEvent";
		public static const CENTER_IMAGE:String = "centerImageEvent";
		public static const SET_ZOOM_TO_ONE:String = "setZoomToOneEvent";
		public static const RETURN_TO_WEB_PAGE:String = "returnToWebPageEvent";
		
		public var panePosition:int = -1;
		public var shiftKeyDown:Boolean;
		
		public function EdgeControlsEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
	}
}