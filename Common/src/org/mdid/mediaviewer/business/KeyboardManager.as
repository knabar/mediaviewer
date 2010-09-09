package org.mdid.mediaviewer.business
{
	import com.asfusion.mate.events.Dispatcher;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	
	import org.mdid.mediaviewer.events.AppStatusEvent;
	import org.mdid.mediaviewer.events.ControlBarClickEvent;
	import org.mdid.mediaviewer.events.EdgeControlsEvent;
	import org.mdid.mediaviewer.events.KeyboardPressEvent;
	import org.mdid.mediaviewer.events.SlideshowEvent;
	import org.mdid.mediaviewer.views.MainView;
	
	public class KeyboardManager extends Sprite
	{
		private var dispatcher:Dispatcher;
		//[Bindable] public var isSlideshowLoaded:Boolean = false;
		public var isSuspended:Boolean = false;
		private var _main:MainView;
		
		public function KeyboardManager(dispatcher:Dispatcher, theStage:Stage, main:MainView)
		{
			this.dispatcher = dispatcher;
			theStage.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
			_main = main;
		}
		private function handleKeyUp(e:KeyboardEvent):void {
			if (_main.isModalPaneDisplayed) return;
			var refreshEvent:AppStatusEvent = new AppStatusEvent(AppStatusEvent.REFRESH_SESSION);
			dispatcher.dispatchEvent(refreshEvent);
			var myEvent:KeyboardPressEvent;
			switch (e.keyCode) {
				//* indicates that control is available in web browser full-screen mode
				//  (other controls are disabled...this is a flash player security feature)
				case 9 : //*tab -- toggle catalog data window hide/show
				case 73 : //i
					myEvent = new KeyboardPressEvent(KeyboardPressEvent.CONTROL_BAR_PROXY_CLICK);
					myEvent.proxyEventType = SlideshowEvent.SHOW_CATALOG_DATA;
					myEvent.isShiftKeyDown = e.shiftKey;
					myEvent.isControlKeyDown = e.ctrlKey;
					dispatcher.dispatchEvent(myEvent);		
				break;
				case 72 : //h -- toggle hide images
					myEvent = new KeyboardPressEvent(KeyboardPressEvent.CONTROL_BAR_PROXY_CLICK);
					myEvent.proxyEventType = ControlBarClickEvent.BLANK_VIEW;
					myEvent.isShiftKeyDown = e.shiftKey;
					myEvent.isControlKeyDown = e.ctrlKey;
					dispatcher.dispatchEvent(myEvent);
				break;
				case 32 : //*space -- toggle scrubbar pane association
					myEvent = new KeyboardPressEvent(KeyboardPressEvent.CONTROL_BAR_PROXY_CLICK);
					myEvent.proxyEventType = ControlBarClickEvent.TOGGLE_PANES;
					myEvent.isShiftKeyDown = e.shiftKey;
					myEvent.isControlKeyDown = e.ctrlKey;
					dispatcher.dispatchEvent(myEvent);
				break;
				case 38 : //*up arrow -- enlarge image
					myEvent = new KeyboardPressEvent(KeyboardPressEvent.CONTROL_BAR_PROXY_CLICK);
					myEvent.proxyEventType = EdgeControlsEvent.ZOOMIN;
					myEvent.isShiftKeyDown = e.shiftKey;
					myEvent.isControlKeyDown = e.ctrlKey;
					dispatcher.dispatchEvent(myEvent);
				break;
				case 40 : //*down arrow -- shrink image
					myEvent = new KeyboardPressEvent(KeyboardPressEvent.CONTROL_BAR_PROXY_CLICK);
					myEvent.proxyEventType = EdgeControlsEvent.ZOOMOUT;
					myEvent.isShiftKeyDown = e.shiftKey;
					myEvent.isControlKeyDown = e.ctrlKey;
					dispatcher.dispatchEvent(myEvent);
				break;
				case 85 : //u -- undo split screen
					myEvent = new KeyboardPressEvent(KeyboardPressEvent.CONTROL_BAR_PROXY_CLICK);
					myEvent.proxyEventType = ControlBarClickEvent.SINGLE_PANE;
					dispatcher.dispatchEvent(myEvent);					
				break;
				case 88 : //x -- split display horizontally (x-axis)
					myEvent = new KeyboardPressEvent(KeyboardPressEvent.CONTROL_BAR_PROXY_CLICK);
					myEvent.proxyEventType = ControlBarClickEvent.DOUBLE_PANE_V;
					dispatcher.dispatchEvent(myEvent);					
				break;
				case 89 : //y -- split display vertically (y-axis)
					myEvent = new KeyboardPressEvent(KeyboardPressEvent.CONTROL_BAR_PROXY_CLICK);
					myEvent.proxyEventType = ControlBarClickEvent.DOUBLE_PANE_H;
					dispatcher.dispatchEvent(myEvent);					
				break;
				case 35 : //end -- go to last slide
					myEvent = new KeyboardPressEvent(KeyboardPressEvent.CONTROL_BAR_PROXY_CLICK);
					myEvent.proxyEventType = ControlBarClickEvent.LAST_SLIDE;
					myEvent.isShiftKeyDown = e.shiftKey;
					myEvent.isControlKeyDown = e.ctrlKey;
					dispatcher.dispatchEvent(myEvent);
				break;
				case 36 : //home -- go to first slide
					myEvent = new KeyboardPressEvent(KeyboardPressEvent.CONTROL_BAR_PROXY_CLICK);
					myEvent.proxyEventType = ControlBarClickEvent.FIRST_SLIDE;
					myEvent.isShiftKeyDown = e.shiftKey;
					myEvent.isControlKeyDown = e.ctrlKey;
					dispatcher.dispatchEvent(myEvent);
				break;
				case 37 : //*left arrow -- go to previous slide (shift + left = go to first slide? no.)
					myEvent = new KeyboardPressEvent(KeyboardPressEvent.CONTROL_BAR_PROXY_CLICK);
					myEvent.proxyEventType = ControlBarClickEvent.PREVIOUS_SLIDE;
					myEvent.isShiftKeyDown = e.shiftKey;
					myEvent.isControlKeyDown = e.ctrlKey;
					dispatcher.dispatchEvent(myEvent);
				break;
				case 39 : //*right arrow -- go to next slide (shift + left = go to first last? no.)
					myEvent = new KeyboardPressEvent(KeyboardPressEvent.CONTROL_BAR_PROXY_CLICK);
					myEvent.proxyEventType = ControlBarClickEvent.NEXT_SLIDE;
					myEvent.isShiftKeyDown = e.shiftKey;
					myEvent.isControlKeyDown = e.ctrlKey;
					dispatcher.dispatchEvent(myEvent);
				break;
			}
		}

	}
}