package org.mdid.mediaviewer.events
{
	import flash.events.Event;

	public class ScrubberEvent extends Event
	{
		public static const SHOW_PREVIEW:String = "showPreviewEvent";
		public static const HIDE_PREVIEW:String = "hidePreviewEvent";
		public static const MOVE_PREVIEW:String = "movePreviewEvent";
		
		public var targetX:int;
		public var slideIdx:int;

		public function ScrubberEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
	}
}