package org.mdid.mediaviewer.events
{
	import flash.events.Event;

	public class AppMenuClickEvent extends Event
	{
		public static const LOGIN:String = "login";
		public static const SLIDESHOWS:String = "slideshows";
		
		public function AppMenuClickEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}