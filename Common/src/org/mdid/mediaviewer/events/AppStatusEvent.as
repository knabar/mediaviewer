package org.mdid.mediaviewer.events
{
	import flash.events.Event;

	public class AppStatusEvent extends Event
	{
		public static const UPDATE_STATUS: String = "updateStatusEvent";
		public static const CONTACT_SERVER: String = "contactServerEvent";
		public static const LOGIN_ATTEMPT: String = "loginAttemptEvent";
		public static const SERVER_CONTACT_ESTABLISHED: String = "serverContactEstablishedEvent";
		public static const UNABLE_TO_MAKE_CACHE_PATH: String = "unableToMakeCachePathEvent";
		public static const LOAD_PREFS_FILE:String = "loadPrefsFileEvent";
		public static const PREFS_FILE_LOAD_COMPLETE:String = "prefsFileLoadCompleteEvent";
		public static const VALIDATE_MDID2_SESSION:String = "validateMDID2SessionEvent";
		public static const VALIDATE_MDID3_SESSION:String = "validateMDID3SessionEvent";
		public static const CALC_BUTTON_STATES:String = "calculateButtonStatesEvent";
		public static const SYNC_BUTTON_STATES:String = "syncButtonStatesEvent";
		public static const REFRESH_SESSION:String = "refreshSessionEvent";
		public static const CONTEXT_MENU_ACTIVITY:String = "contextMenuActivityEvent";
		public static const KEYBOARD_ACTIVITY:String = "keyboardActivityEvent";
		public static const FULLSCREEN_EVENT_DETECTED:String = "fullscreenEventDetectedEvent";
		public static const HAVE_MULTIPLE_SCREENS:String = "haveMultipleScreensEvent";
		public static const INVOKE_REFRESH_SESSION_HTTPSERVICE_MDID2:String = "invokeRefreshSessionHttpServiceMdid2Event";
		public static const INVOKE_REFRESH_SESSION_HTTPSERVICE_MDID3:String = "invokeRefreshSessionHttpServiceMdid3Event";
		
		public var message:String;
		public var loginSuccessful:Boolean;
		public var synButtonObj:Object;
		public var curSlideIdx1:uint;
		public var curSlideIdx2:uint;
		public var numSlides:uint;
		public var cachingIdx:uint;
		public var slideshowIsPlaying:Boolean;
		public var isPairwiseModeEnabled:Boolean;
		public var contextMenuEventType:String;
		
		public function AppStatusEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
	}
}