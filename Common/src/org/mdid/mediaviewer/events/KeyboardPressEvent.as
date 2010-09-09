package org.mdid.mediaviewer.events
{
	import flash.events.Event;

	public class KeyboardPressEvent extends Event
	{
		public static const CONTROL_BAR_PROXY_CLICK:String = "controlBarClickProxyEvent";

		public var proxyEventType:String;
		public var isShiftKeyDown:Boolean = false;
		public var isControlKeyDown:Boolean = false;
		
		public function KeyboardPressEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}