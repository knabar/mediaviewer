package org.mdid.mediaviewer.vo
{
    import com.asfusion.mate.events.Dispatcher;
    
    import flash.display.StageDisplayState;
    import flash.events.ContextMenuEvent;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    
    import mx.containers.Canvas;
    import mx.core.Application;
    
    import org.mdid.mediaviewer.events.AppStatusEvent;
    import org.mdid.mediaviewer.events.ControlBarClickEvent;
    import org.mdid.mediaviewer.events.EdgeControlsEvent;
    import org.mdid.mediaviewer.events.SlideshowEvent;

    public class MdidContextMenu {
		private static var buttonStates:Object = new Object();
		private var _contextMenu:ContextMenu;
		private var _dispatcher:Dispatcher;
		private var _menuType:String;
		private var _currentPanePosition:int = 1;
		private var _itemGoToMySlideshows:ContextMenuItem = new ContextMenuItem('Return to "My Slideshows"');
		private var _itemMediaViewerHelp:ContextMenuItem = new ContextMenuItem("MediaViewer Help");
		private var _itemGoToMDIDHelp:ContextMenuItem = new ContextMenuItem("MDID Help Site");
		private var _itemVersion:ContextMenuItem = new ContextMenuItem("MediaViewer v" + Settings.CURRENT_VERSION);
		private var _itemCopyright:ContextMenuItem = new ContextMenuItem("© JMU 2010");
		private var _itemExitEnterFullscreen:ContextMenuItem = new ContextMenuItem("");
		private var _exitFullscreenCaption:String = "Exit Fullscreen Mode";
		private var _enterFullscreenCaption:String = "Enter Fullscreen Mode";
		private var _itemShowHideCatData:ContextMenuItem = new ContextMenuItem("");
		private var _showCatDataCaption:String = "Show Catalog Data";
		private var _hideCatDataCaption:String = "Hide Catalog Data";
		private var _itemToggleCatData:ContextMenuItem = new ContextMenuItem("Toggle Catalog Data");
		private var _itemUndoSplit:ContextMenuItem = new ContextMenuItem("Undo Split Display");
		private var _itemSplitHorizontally:ContextMenuItem = new ContextMenuItem("Split Display Horizontally");
		private var _itemSplitVertically:ContextMenuItem = new ContextMenuItem("Split Display Vertically");
		private var _itemRepositionThis:ContextMenuItem = new ContextMenuItem("Reposition This Image");
		private var _itemRepositionBoth:ContextMenuItem = new ContextMenuItem("Reposition Both Images");
		private var _itemResizeThis:ContextMenuItem = new ContextMenuItem("Resize This Image to 100%");
		private var _itemResizeBoth:ContextMenuItem = new ContextMenuItem("Resize Both Images to 100%");
		private var _itemShowHideThisImage:ContextMenuItem = new ContextMenuItem("");
		private var _showThisImageCaption:String = "Show This Image";
		private var _hideThisImageCaption:String = "Hide This Image";
		private var _itemFirst:ContextMenuItem = new ContextMenuItem("Go to First Image");
		private var _itemPrevious:ContextMenuItem = new ContextMenuItem("Go to Previous Image");
		private var _itemNext:ContextMenuItem = new ContextMenuItem("Go to Next Image");
		private var _itemLast:ContextMenuItem = new ContextMenuItem("Go to Last Image");
	
		public function MdidContextMenu(theCanvas:Canvas, theMenuType:String, dispatcher:Dispatcher) {
			_dispatcher = dispatcher;
		    _contextMenu = new ContextMenu();
		    _contextMenu.hideBuiltInItems();
		    _menuType = theMenuType.toLowerCase();
		    addCustomMenuItems();
		    _contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT, menuSelectHandler);
		    theCanvas.contextMenu = _contextMenu;
		}
		private function addCustomMenuItems():void {
			if (this._menuType != "mainview") {
				_itemFirst.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemSelectHandler);
				_contextMenu.customItems.push(_itemFirst);
				_itemPrevious.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemSelectHandler);
				_contextMenu.customItems.push(_itemPrevious);
				_itemNext.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemSelectHandler);
				_contextMenu.customItems.push(_itemNext);
				_itemLast.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemSelectHandler);
				_contextMenu.customItems.push(_itemLast);
				
				_itemShowHideThisImage.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemSelectHandler);
				_itemShowHideThisImage.separatorBefore = true;
				_contextMenu.customItems.push(_itemShowHideThisImage);
				_itemResizeThis.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemSelectHandler);
				_contextMenu.customItems.push(_itemResizeThis);
				_itemRepositionThis.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemSelectHandler);
				_contextMenu.customItems.push(_itemRepositionThis);
//				if (this._menuType != "singlepane") {
//					_itemResizeBoth.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemSelectHandler);
//					_contextMenu.customItems.push(_itemResizeBoth);
//					_itemRepositionBoth.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemSelectHandler);
//					_contextMenu.customItems.push(_itemRepositionBoth);
//				}
				
				_itemShowHideCatData.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemSelectHandler);
				_contextMenu.customItems.push(_itemShowHideCatData);
				_itemShowHideCatData.separatorBefore = true;
				
				if (this._menuType == "singlepane") {
					_itemSplitHorizontally.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemSelectHandler);
					_contextMenu.customItems.push(_itemSplitHorizontally);
					_itemSplitHorizontally.separatorBefore = true;
					_itemSplitVertically.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemSelectHandler);
					_contextMenu.customItems.push(_itemSplitVertically);
				} else {
					_itemUndoSplit.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemSelectHandler);
					_itemUndoSplit.separatorBefore = true;
					_contextMenu.customItems.push(_itemUndoSplit);
				}
				_itemMediaViewerHelp.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemSelectHandler);
				_contextMenu.customItems.push(_itemMediaViewerHelp);
				_itemMediaViewerHelp.separatorBefore = true;
			}
	
			if (this._menuType == "mainview") {
				
				_itemExitEnterFullscreen.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemSelectHandler);
				_contextMenu.customItems.push(_itemExitEnterFullscreen);
				
				_itemGoToMySlideshows.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemSelectHandler);
				_contextMenu.customItems.push(_itemGoToMySlideshows);
				
				_itemMediaViewerHelp.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemSelectHandler);
				_contextMenu.customItems.push(_itemMediaViewerHelp);
				_itemMediaViewerHelp.separatorBefore = true;
				
				_itemGoToMDIDHelp.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemSelectHandler);
				_contextMenu.customItems.push(_itemGoToMDIDHelp);
				
				_itemVersion.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemSelectHandler);
				_contextMenu.customItems.push(_itemVersion);
				_itemVersion.separatorBefore = true;
				
				_itemCopyright.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemSelectHandler);
				_contextMenu.customItems.push(_itemCopyright);
			}
		}
	
		public static function setSyncButtons(obj:Object):void {
			buttonStates = obj;
		}
		private function menuSelectHandler(e:ContextMenuEvent):void {
			this._currentPanePosition = 1;
		   	switch (this._menuType.toLowerCase()) {
				case "mainview" :
					this._itemExitEnterFullscreen.caption = (Application.application.stage.displayState == StageDisplayState.NORMAL) ? this._enterFullscreenCaption : this._exitFullscreenCaption;
					break;
				case "singlepane" :				
					this._itemFirst.enabled = buttonStates.firstIsEnabled1;
					this._itemPrevious.enabled = buttonStates.previousIsEnabled1;
					this._itemNext.enabled = buttonStates.nextIsEnabled1;
					this._itemLast.enabled = buttonStates.lastIsEnabled1;
					_itemShowHideThisImage.caption = e.contextMenuOwner["blank"].visible == true ? this._showThisImageCaption : this._hideThisImageCaption;
					this._itemShowHideCatData.caption = e.contextMenuOwner["catWindow"].visible == true ? this._hideCatDataCaption : this._showCatDataCaption;
					break;
				case "doublepanehdiv" :
				case "doublepanevdiv" :
					if (e.mouseTarget.hasOwnProperty("id") && e.mouseTarget["id"] == "blank1") {
						this._currentPanePosition = 1;
					} else if (e.mouseTarget.hasOwnProperty("id") && e.mouseTarget["id"] == "blank2") {
						this._currentPanePosition = 2;
					} else {
						var obj:Object = e.mouseTarget;
						while (obj != null) {
							if (obj.hasOwnProperty("panePosition")) {
								this._currentPanePosition = obj["panePosition"];
								break;
							}
							if (obj.parent != null) {
								obj = obj.parent;
							} else {
								obj = null;
							}
						}
					}
					this._itemFirst.enabled = (this._currentPanePosition == 1) ? buttonStates.firstIsEnabled1 : buttonStates.firstIsEnabled2;
					this._itemPrevious.enabled = (this._currentPanePosition == 1) ? buttonStates.previousIsEnabled1 :  buttonStates.previousIsEnabled2;
					this._itemNext.enabled = (this._currentPanePosition == 1) ? buttonStates.nextIsEnabled1 : buttonStates.nextIsEnabled2;
					this._itemLast.enabled = (this._currentPanePosition == 1) ? buttonStates.lastIsEnabled1 : buttonStates.lastIsEnabled2;
					_itemShowHideThisImage.caption = e.contextMenuOwner["blank"+this._currentPanePosition.toString()].visible == true ? this._showThisImageCaption : this._hideThisImageCaption;
					this._itemShowHideCatData.caption = e.contextMenuOwner["catWindow"+this._currentPanePosition.toString()].visible ?  this._hideCatDataCaption : this._showCatDataCaption;
					break;
			}

			var myEvent:AppStatusEvent = new AppStatusEvent(AppStatusEvent.CONTEXT_MENU_ACTIVITY);
			myEvent.contextMenuEventType = e.type;
			_dispatcher.dispatchEvent(myEvent);
		}
		
		private function menuItemSelectHandler(e:ContextMenuEvent):void {
			var myEvent:AppStatusEvent = new AppStatusEvent(AppStatusEvent.CONTEXT_MENU_ACTIVITY);
			myEvent.contextMenuEventType = e.type;
			_dispatcher.dispatchEvent(myEvent);
			var myEdgeEvent:EdgeControlsEvent;
			var myMouseTarget:Object = e.mouseTarget;
			switch (e.currentTarget) {
				case _itemGoToMySlideshows :
					this._dispatcher.dispatchEvent(new EdgeControlsEvent(EdgeControlsEvent.RETURN_TO_WEB_PAGE));
				break;
				case _itemMediaViewerHelp :
					if (GeneralFactory.getInstance().runmode == GeneralFactory.WEB_MODE) {
						GeneralFactory.getInstance().jumpToUrl(GeneralFactory.getInstance().mediaviewerhelpurl, "_blank");
					}
				break;
				case _itemGoToMDIDHelp :
					if (GeneralFactory.getInstance().runmode == GeneralFactory.WEB_MODE) {
						GeneralFactory.getInstance().jumpToUrl(GeneralFactory.getInstance().mdidhelpurl, "_blank");
					}
				break;
				case _itemExitEnterFullscreen :
					GeneralFactory.getInstance().toggleFullScreen();
				break;
				case _itemShowHideCatData :
					var myCatEvent:SlideshowEvent;
					if (this._currentPanePosition == 1){
						myCatEvent = new SlideshowEvent(SlideshowEvent.SHOW_CATALOG_DATA_1);
					} else {
						myCatEvent = new SlideshowEvent(SlideshowEvent.SHOW_CATALOG_DATA_2);
					}
					myCatEvent.isDispatchedFromTopBar = false;
					this._dispatcher.dispatchEvent(myCatEvent);
				break;
				case _itemToggleCatData :
				//not implemented
				break;
				case _itemUndoSplit :
					this._dispatcher.dispatchEvent(new ControlBarClickEvent(ControlBarClickEvent.SINGLE_PANE));				
				break;
				case _itemSplitHorizontally :
					this._dispatcher.dispatchEvent(new ControlBarClickEvent(ControlBarClickEvent.DOUBLE_PANE_V));
				break;
				case _itemSplitVertically :
					this._dispatcher.dispatchEvent(new ControlBarClickEvent(ControlBarClickEvent.DOUBLE_PANE_H));
				break;
				case _itemRepositionThis :
					var myRepositionEvent:EdgeControlsEvent = new EdgeControlsEvent(EdgeControlsEvent.CENTER_IMAGE);
					myRepositionEvent.panePosition = this._currentPanePosition;
					this._dispatcher.dispatchEvent(myRepositionEvent);
				break;
				case _itemRepositionBoth :
				//not implemented
				break;
				case _itemResizeThis :
					var myResizeEvent:EdgeControlsEvent = new EdgeControlsEvent(EdgeControlsEvent.SET_ZOOM_TO_ONE);
					myResizeEvent.panePosition = this._currentPanePosition;
					this._dispatcher.dispatchEvent(myResizeEvent);
				break;
				case _itemResizeBoth :
				//not implemented
				break;
				case _itemShowHideThisImage :
					if (this._menuType.toLowerCase() == "singlepane") {
						this._dispatcher.dispatchEvent(new ControlBarClickEvent(ControlBarClickEvent.BLANK_VIEW));
					} else if (this._menuType.toLowerCase() == "doublepanehdiv" || this._menuType.toLowerCase() == "doublepanevdiv") {
						var paneVisibilityEvent:ControlBarClickEvent = new ControlBarClickEvent(ControlBarClickEvent.BLANK_SINGLE_PANE);
						paneVisibilityEvent.panePosition = this._currentPanePosition;
						this._dispatcher.dispatchEvent(paneVisibilityEvent);
					}
				break;
				case _itemFirst :
					myEdgeEvent = new EdgeControlsEvent(EdgeControlsEvent.PREVIOUS_SLIDE);
					myEdgeEvent.panePosition = this._currentPanePosition;
					myEdgeEvent.shiftKeyDown = true;
					this._dispatcher.dispatchEvent(myEdgeEvent);				
				break;
				case _itemPrevious :
					myEdgeEvent = new EdgeControlsEvent(EdgeControlsEvent.PREVIOUS_SLIDE);
					myEdgeEvent.panePosition = this._currentPanePosition;
					myEdgeEvent.shiftKeyDown = false;
					this._dispatcher.dispatchEvent(myEdgeEvent);				
				break;
				case _itemNext :
					myEdgeEvent = new EdgeControlsEvent(EdgeControlsEvent.NEXT_SLIDE);
					myEdgeEvent.panePosition = this._currentPanePosition;
					myEdgeEvent.shiftKeyDown = false;
					this._dispatcher.dispatchEvent(myEdgeEvent);				
				break;
				case _itemLast :
					myEdgeEvent = new EdgeControlsEvent(EdgeControlsEvent.NEXT_SLIDE);
					myEdgeEvent.panePosition = this._currentPanePosition;
					myEdgeEvent.shiftKeyDown = true;
					this._dispatcher.dispatchEvent(myEdgeEvent);				
				break;
				default :
					//trace(e.currentTarget);
				break;
			}
		}
	}
}