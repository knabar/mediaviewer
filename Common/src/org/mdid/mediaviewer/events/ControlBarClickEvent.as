package org.mdid.mediaviewer.events
{
	import flash.events.Event;

	public class ControlBarClickEvent extends Event
	{
		public static const PIN_TOPBAR:String = "pinTopBarEvent";
		public static const UNPIN_TOPBAR:String = "unpinTopBarEvent";
		public static const PIN_APPBAR:String = "pinAppBarEvent";
		public static const UNPIN_APPBAR:String = "unpinAppBarEvent";
		public static const ROLLUP_TOPBAR:String = "rollUpTopBarEvent";
		public static const ROLLDOWN_TOPBAR:String = "rollDownTopBarEvent";
		public static const ROLLUP_APPBAR:String = "rollUpAppBarEvent";
		public static const ROLLDOWN_APPBAR:String = "rollDownAppBarEvent";
		public static const ROLLUP_APPMENU:String = "rollUpAppMenuEvent";
		public static const ROLLDOWN_APPMENU:String = "rollDownAppMenuEvent";
		public static const SINGLE_PANE:String = "singlePaneEvent";
		public static const DOUBLE_PANE_H:String = "doublePaneHDivEvent";
		public static const DOUBLE_PANE_V:String = "doublePaneVDivEvent";
		public static const TOGGLE_PANES:String = "togglePanesEvent";
		public static const TOGGLE_DUAL_SCREENS:String = "toggleDualScreensEvent";
		public static const BLANK_VIEW:String = "blankViewEvent";
		public static const BLANK_SINGLE_PANE:String = "blankSinglePaneEvent";
		public static const NEXT_SLIDE:String = "advanceToNextSlideEvent";
		public static const PREVIOUS_SLIDE:String = "advanceToPreviousSlideEvent";
		public static const LAST_SLIDE:String = "advanceToLastSlideEvent";
		public static const FIRST_SLIDE:String = "advanceToFirstSlideEvent";
		public static const GO_TO_SLIDE:String = "goToSlideEvent";
		public static const START_SHOW:String = "startShowEvent";
		public static const STOP_SHOW:String = "stopShowEvent";
		public static const REFRESH_BUTTON_STATES:String = "refreshButtonStatesEvent";
		public static const TOGGLE_PAIRWISE_MODE:String = "togglePairwiseModeEvent";
		
		public var panePosition:int = -1;
		public var slideIdx:int;
		public var delayInSeconds:int;
		public var enablePairwiseMode:Boolean = false;
		
		public function ControlBarClickEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}