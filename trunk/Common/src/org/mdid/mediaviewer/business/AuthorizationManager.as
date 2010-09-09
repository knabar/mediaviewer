package org.mdid.mediaviewer.business
{
	import flash.events.IEventDispatcher;
	import org.mdid.mediaviewer.events.AppStatusEvent;
	import org.mdid.mediaviewer.events.SlideshowListEvent;

	public class AuthorizationManager
	{
		private var dispatcher:IEventDispatcher;

		[Bindable] public var sessionToken:String;
		[Bindable] public var isLoggedIn:Boolean = false;
		
        public function AuthorizationManager(dispatcher:IEventDispatcher) {
            this.dispatcher = dispatcher;
        }
		public function logout():void {
			this.sessionToken = "";
			this.isLoggedIn = false;
		}
		public function parseLoginResults(result:Object):Object {
			var loginObject:Object = new Object();
			loginObject.resultCode = result.resultcode;
			if (loginObject.resultCode == "SUCCESS") {
				isLoggedIn = true;
				loginObject.errorMessage = "";
				sessionToken = result.sessiontoken;
				var myEvent:SlideshowListEvent = new SlideshowListEvent(SlideshowListEvent.LOAD);
				myEvent.slideshows = result.slideshows;
				dispatcher.dispatchEvent(myEvent);
				var myEvent2:AppStatusEvent = new AppStatusEvent(AppStatusEvent.UPDATE_STATUS);
				myEvent2.message = "You are now connected to your MDID server.";
				dispatcher.dispatchEvent(myEvent2);
			} else {
				isLoggedIn = false;
				loginObject.errorMessage = result.errormessage;
			}
			var myAttemptEvent:AppStatusEvent = new AppStatusEvent(AppStatusEvent.LOGIN_ATTEMPT);
			myAttemptEvent.loginSuccessful = isLoggedIn;
			dispatcher.dispatchEvent(myAttemptEvent);
			return loginObject;
		}
		
		public function handleLoginFault(fault:Object):Object {
			trace(fault);
			return fault;
		}
	}
}