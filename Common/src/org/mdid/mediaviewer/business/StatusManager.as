package org.mdid.mediaviewer.business
{
	import com.adobe.serialization.json.JSONDecoder;
	
	import flash.events.IEventDispatcher;
	
	import mx.utils.*;
	
	import org.mdid.mediaviewer.events.AppMenuClickEvent;
	import org.mdid.mediaviewer.events.AppStatusEvent;
	import org.mdid.mediaviewer.events.SlideshowEvent;
	import org.mdid.mediaviewer.events.SlideshowListEvent;
	
	public class StatusManager {
		
		private var dispatcher:IEventDispatcher;
		private var refreshIntervalMilliseconds:int = 1000; // 1000*60*5;
		private var lastSessionRefresh:Date = new Date();
		private var isLoggedIn:Boolean = false;
		private var isStatusMessageLocked:Boolean = false;
		
		[Bindable] public var statusMessage:String = "Welcome to the MDID MediaViewer";
		[Bindable] public var keepAliveUrl:String;
		[Bindable] public var mdidVersion:String;
		[Bindable] public var topBarIsPinned:Boolean; 
		[Bindable] public var isServerContacted:Boolean = false;
		[Bindable] public var secureLoginRequired:Boolean;
		
		public function StatusManager(dispatcher:IEventDispatcher) {
            this.dispatcher = dispatcher;
			this.mdidVersion = GeneralFactory.MDID2;
            if (GeneralFactory.getInstance().runmode == GeneralFactory.WEB_MODE) {
            	if (GeneralFactory.getInstance().queryStringItem("id") == null) {
	        		var temp:String = GeneralFactory.getInstance().flashVarItem("version");
	        		if (temp != null && temp.length > 0) {
	        			if (temp.toLowerCase() == "mdid3") {
	        				this.mdidVersion = GeneralFactory.MDID3;
			        		temp = GeneralFactory.getInstance().flashVarItem("keepAliveUrl");
			        		if (temp != null && temp.length > 0) {
			        			this.keepAliveUrl = temp;
			        			GeneralFactory.getInstance().keepaliveurl = this.keepAliveUrl;
			        		}
			        		temp = GeneralFactory.getInstance().flashVarItem("returnToUrl");
			        		if (temp != null && temp.length > 0) {
			        			GeneralFactory.getInstance().returntourl = temp;
			        		}
			        		temp = GeneralFactory.getInstance().flashVarItem("mdidHelpUrl");
			        		if (temp != null && temp.length > 0) {
			        			GeneralFactory.getInstance().mdidhelpurl = temp;
			        		} else {
			        			GeneralFactory.getInstance().mdidhelpurl = Settings.MDID3_SUPPORT_WEB_SITE;
			        		}
			        		temp = GeneralFactory.getInstance().flashVarItem("mediaviewerHelpUrl");
			        		if (temp != null && temp.length > 0) {
			        			GeneralFactory.getInstance().mediaviewerhelpurl = temp;
			        		} else {
			        			GeneralFactory.getInstance().mediaviewerhelpurl = Settings.MDID3_SUPPORT_WEB_SITE_MEDIAVIEWER;
			        		}
	        			}
	        		}
            	}
            }
            GeneralFactory.getInstance().mdidversion = this.mdidVersion;
            if (GeneralFactory.getInstance().mdidversion == GeneralFactory.MDID2) {
            	var val:String = GeneralFactory.getInstance().runmode == GeneralFactory.WEB_MODE ? GeneralFactory.getInstance().queryStringItem("return") : "";
				GeneralFactory.getInstance().returntourl = (val != null && val.length > 1) ? "../" + val : Settings.RETURN_TO_WEB_PAGE_MDID2;
				GeneralFactory.getInstance().mdidhelpurl = Settings.MDID2__HELP;
				GeneralFactory.getInstance().mediaviewerhelpurl = Settings.MDID2_MEDIAVIEWER_HELP;
            }
		}
		public function refreshSession():void {
			if (!isLoggedIn) return;
			var currentTime:Date = new Date();
			var timeDiff:int = currentTime.time - this.lastSessionRefresh.time;
			if (timeDiff > this.refreshIntervalMilliseconds) {
				if (GeneralFactory.getInstance().runmode == GeneralFactory.WEB_MODE || GeneralFactory.getInstance().runmode == GeneralFactory.AIR_MODE) {
					var refreshEvent:AppStatusEvent = new AppStatusEvent(GeneralFactory.getInstance().mdidversion == GeneralFactory.MDID2 ? AppStatusEvent.INVOKE_REFRESH_SESSION_HTTPSERVICE_MDID2 : AppStatusEvent.INVOKE_REFRESH_SESSION_HTTPSERVICE_MDID3);
					dispatcher.dispatchEvent(refreshEvent);
				}
				this.lastSessionRefresh = currentTime;
			}
		}
		public function updateKeepAliveUrl():void {
			var idx:int = this.keepAliveUrl.lastIndexOf("?");
			var d:Date = new Date();
			if (idx < 0) {
				this.keepAliveUrl += "?" + d.time;
			} else {
				this.keepAliveUrl = this.keepAliveUrl.substring(0, idx) + "?" + d.time;
			}
		}
		public function logout():void {
			this.isLoggedIn = false;
			updateMessage("You have successfully logged out of MDID.");
		}
		public function handleIsSessionAliveMDID3(result:Object):void {
			isLoggedIn = true;
			var jd:JSONDecoder = new JSONDecoder(result.toString());
			var res:String = jd.getValue().result == null ? "" : jd.getValue().result;
			var user:String = jd.getValue().user == null ? "" : jd.getValue().user;
			if (res.toLowerCase() != "ok" || user.length < 1) {
				isLoggedIn = false;
				//throw up error dialog box
				var myErrorMessage:AppStatusEvent = new AppStatusEvent(AppStatusEvent.UPDATE_STATUS);
				myErrorMessage.message = "ALERT: You are not logged in or your session has expired. Return to your MDID and login again.";
				dispatcher.dispatchEvent(myErrorMessage);
				this.isStatusMessageLocked = true;
				var mySlideshowListEvent:SlideshowListEvent = new SlideshowListEvent(SlideshowListEvent.INVALIDATE_ALL_IMAGES);
				dispatcher.dispatchEvent(mySlideshowListEvent);
			}
		}
		public function updateMessage(msg:String):void {
			if (this.isStatusMessageLocked) return;
			statusMessage = msg;
		}
		public function handleServerContact(result:Object):Object {
			isServerContacted = true;
			secureLoginRequired = result.securelogin;
			var myMessage:AppStatusEvent = new AppStatusEvent(AppStatusEvent.UPDATE_STATUS);
			myMessage.message = "MDID Server is available. Please log in now.";
			dispatcher.dispatchEvent(myMessage);
			var myContactEvent:AppStatusEvent = new AppStatusEvent(AppStatusEvent.SERVER_CONTACT_ESTABLISHED);
			dispatcher.dispatchEvent(myContactEvent);
			var myLoginEvent:AppMenuClickEvent = new AppMenuClickEvent(AppMenuClickEvent.LOGIN);
			dispatcher.dispatchEvent(myLoginEvent);
			return result;
		}
		public function handleValidateMDID2Session(result:Object):void {
			isServerContacted = true;
			secureLoginRequired = false;
			isLoggedIn = result.isactive;
			var myAttemptEvent:AppStatusEvent = new AppStatusEvent(AppStatusEvent.LOGIN_ATTEMPT);
			myAttemptEvent.loginSuccessful = isLoggedIn;
			dispatcher.dispatchEvent(myAttemptEvent);
			if (isLoggedIn) {
				var myGetSlideshowInfoEvent:SlideshowEvent = new SlideshowEvent(SlideshowEvent.GET_SLIDESHOW_INFO_MDID2);
				if (GeneralFactory.getInstance().queryStringItem("id") != null && GeneralFactory.getInstance().queryStringItem("id").length < 1) {
					var myErrorMessage:AppStatusEvent = new AppStatusEvent(AppStatusEvent.UPDATE_STATUS);
					myErrorMessage.message = "ALERT: You are not logged in or your session has expired. Return to your MDID and login again.";
					dispatcher.dispatchEvent(myErrorMessage);
				} else {
					myGetSlideshowInfoEvent.slideshowID = GeneralFactory.getInstance().queryStringItem("id");
				}
				dispatcher.dispatchEvent(myGetSlideshowInfoEvent);
			} else {
				//throw up error dialog box
				var myErrorMessage2:AppStatusEvent = new AppStatusEvent(AppStatusEvent.UPDATE_STATUS);
				myErrorMessage2.message = "ALERT: You are not logged in or your session has expired. Return to your MDID and login again.";
				dispatcher.dispatchEvent(myErrorMessage2);
			}
		}
		public function handleValidateMDID3Session(result:Object):void {
			isServerContacted = true;
			isLoggedIn = false;
			secureLoginRequired = false;
			var jd:JSONDecoder = new JSONDecoder(result.toString());
			var res:String = jd.getValue().result == null ? "" : jd.getValue().result;
			var user:String = jd.getValue().user == null ? "" : jd.getValue().user;
			if (res.toLowerCase() != "ok" || user.length < 1) {
				//throw up error dialog box
				var myErrorMessage:AppStatusEvent = new AppStatusEvent(AppStatusEvent.UPDATE_STATUS);
				myErrorMessage.message = "ALERT: You are not logged in or your session has expired. Return to your MDID and login again.";
				dispatcher.dispatchEvent(myErrorMessage);
			} else {
				isLoggedIn = true;
				var myGetPresentationEvent:SlideshowEvent = new SlideshowEvent(SlideshowEvent.GET_PRESENTATION_MDID3);
				if (GeneralFactory.getInstance().flashVarItem("presentationUrl") == null || GeneralFactory.getInstance().flashVarItem("presentationUrl").length < 1) {
					var myErrorMessage2:AppStatusEvent = new AppStatusEvent(AppStatusEvent.UPDATE_STATUS);
					myErrorMessage2.message = "ALERT: Unable to retrieve slideshow. Return to your MDID and try again.";
					dispatcher.dispatchEvent(myErrorMessage2);
				} else {
					var myAttemptEvent:AppStatusEvent = new AppStatusEvent(AppStatusEvent.LOGIN_ATTEMPT);
					myAttemptEvent.loginSuccessful = isLoggedIn;
					dispatcher.dispatchEvent(myAttemptEvent);
					myGetPresentationEvent.presentationUrl = GeneralFactory.getInstance().flashVarItem("presentationUrl");
				}
				dispatcher.dispatchEvent(myGetPresentationEvent);
			}
		}
		public function handleFault(fault:Object):Object {
			trace(fault);
			return fault;
		}
		public function setTopBarIsPinned(theState:Boolean):void {
			this.topBarIsPinned = theState;
		}
	}
}