package org.mdid.mediaviewer.events
{
	import flash.events.Event;
	import mx.collections.ArrayCollection;
	
	public class SlideshowListEvent extends Event
	{
		public static const LOAD:String = "loadEvent";
		public static const INVALIDATE_ALL_IMAGES:String = "invalidateAllImagesEvent";
		public static const UNLOAD_CURRENT_SLIDESHOW:String = "unloadCurrentSlideshowEvent";

		public var slideshows:ArrayCollection;

		public function SlideshowListEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}

	}
}