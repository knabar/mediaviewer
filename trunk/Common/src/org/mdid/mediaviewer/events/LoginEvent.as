package org.mdid.mediaviewer.events
{
	import flash.events.Event;

	public class LoginEvent extends Event
	{		
		public static const LOGIN: String = "loginEvent";
		public static const SSL_LOGIN: String = "sslLoginEvent";
		public static const LOGOUT: String = "logoutEvent";
		public static const LOGIN_SUCCESSFUL:String = "loginSuccessfulEvent";
		
		public var username : String;
		public var password : String;

		public function LoginEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
	}
}