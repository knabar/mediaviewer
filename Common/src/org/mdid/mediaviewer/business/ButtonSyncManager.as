package org.mdid.mediaviewer.business
{
	import flash.events.IEventDispatcher;
	
	import org.mdid.mediaviewer.events.AppStatusEvent;

	public class ButtonSyncManager
	{
		private var dispatcher:IEventDispatcher;
		private var syncObject:Object = new Object();
		
		public function ButtonSyncManager(dispatcher:IEventDispatcher):void {
            this.dispatcher = dispatcher;
		}
		public function syncButtons(idx1:int, idx2:int, numSlides:int, cachingIdx:int, slideshowIsPlaying:Boolean, isPairwiseModeEnabled:Boolean):void {
			var mySyncButtonsEvent:AppStatusEvent = new AppStatusEvent(AppStatusEvent.SYNC_BUTTON_STATES);
			syncObject.currentIdx1 = idx1;
			syncObject.currentIdx2 = idx2;
			syncObject.slideshowIsPlaying = slideshowIsPlaying;
			//cachingIdx--;
			syncObject.firstIsEnabled1 = idx1 > 0 && cachingIdx > 0;
			syncObject.firstIsEnabled2 =   isPairwiseModeEnabled ? syncObject.firstIsEnabled1 : idx2 > 0 && cachingIdx > 0;
			syncObject.previousIsEnabled1 = syncObject.firstIsEnabled1;
			syncObject.previousIsEnabled2 = syncObject.firstIsEnabled2;
			syncObject.nextIsEnabled1 = idx1 < numSlides - 1 && idx1 < cachingIdx;
			syncObject.nextIsEnabled2 = isPairwiseModeEnabled ? syncObject.nextIsEnabled1 : idx2 < numSlides - 1 && idx2 < cachingIdx;
			syncObject.lastIsEnabled1 = syncObject.nextIsEnabled1 && cachingIdx >= numSlides;
			syncObject.lastIsEnabled2 = syncObject.nextIsEnabled2 && cachingIdx >= numSlides;
			syncObject.playIsEnabled1 = numSlides > 1 && syncObject.lastIsEnabled1;
			syncObject.playIsEnabled2 = numSlides > 1 && syncObject.lastIsEnabled2;
			syncObject.screensEnabled = numSlides > 0 && idx1 > -1 && cachingIdx > 0;
			mySyncButtonsEvent.synButtonObj = syncObject;
			dispatcher.dispatchEvent(mySyncButtonsEvent);
		}

	}
}