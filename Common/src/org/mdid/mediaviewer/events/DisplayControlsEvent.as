package org.mdid.mediaviewer.events {
	import flash.events.Event;

	public class DisplayControlsEvent extends Event {
		public static const SHOW_CONTROLS:String = "showControlsEvent";
		public static const HIDE_CONTROLS:String = "hideControlsEvent";
		
		public function DisplayControlsEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
	}
}