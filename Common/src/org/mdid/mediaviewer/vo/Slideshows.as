package org.mdid.mediaviewer.vo
{
	import mx.collections.ArrayCollection;
	import mx.collections.XMLListCollection;
	
	public class Slideshows
	{
		[Bindable]
		public var slideshowsAll:XMLListCollection;
		
		[Bindable]
		public var slideshowsUnarchived:XMLListCollection;
		
		public function Slideshows():void {
			trace("Slideshows constructor");
		}
		
		public function loadSlideshowList(theSlideshows:ArrayCollection):void
		{
			var myRootAll:XML = new XML(<root/>);
			var myRootUnarchived:XML = new XML(<root/>);
			for each(var item:Object in theSlideshows) {
				var myFolderAll:XML = new XML(<node/>);
				var myFolderUnarchived:XML = new XML(<node/>);
				for each(var subitem:Object in item) {
					if (subitem is String) {
						myFolderAll[0].@label = subitem;
						myFolderAll[0].@isFolder = "true";
						myFolderUnarchived[0].@label = subitem;
						myFolderUnarchived[0].@isFolder = "true";
					} else {
						var myFile:XML = new XML(<node/>);
						myFile.@isFolder = "false";
						myFile.@label = subitem.value;
						myFile.@archived = subitem.archived;
						myFile.@id = subitem.id;
						if (myFile.@archived == "true") {
							myFile.@icon = "iconSymbolArchived";
						} else {
							myFile.@icon = "iconSymbolUnarchived";
							var copyFile:XML = new XML(myFile);
							myFolderUnarchived.appendChild(copyFile);
						}
						myFolderAll.appendChild(myFile);
					}
				}
				myRootAll.appendChild(myFolderAll);
				myRootUnarchived.appendChild(myFolderUnarchived);
			}
			sortXmlAttribute(myRootAll, "label", false, Array.CASEINSENSITIVE);
			sortXmlAttribute(myRootUnarchived, "label", false, Array.CASEINSENSITIVE);
			slideshowsAll = new XMLListCollection(new XMLList(myRootAll.children()));
			slideshowsUnarchived = new XMLListCollection(new XMLList(myRootUnarchived.children()));
		}
				
        public static function sortXmlAttribute(avXml:XML, avAttributeName:String, avPutEmptiesAtBottom :Boolean,
			avArraySortArgument0:* = 0, avArraySortArgument1:* = 0):void {
			var lvChildrenCount:int = avXml.children().length();
			if( lvChildrenCount == 0 )
				return;
			if ( lvChildrenCount > 1 )
			{
				var lvAttributeValue:String;
				var lvXml:XML;
				var lvSortOptions:int = avArraySortArgument0 is Function ? avArraySortArgument1 : avArraySortArgument0;
				var lvSortCaseInsensitive:Boolean = ( lvSortOptions & Array.CASEINSENSITIVE ) == Array.CASEINSENSITIVE;
				var lvArray:Array = new Array();
				
				for each( lvXml in avXml.children() ) {
					lvAttributeValue = lvXml.attribute( avAttributeName );
					if( lvSortCaseInsensitive )
						lvAttributeValue = lvAttributeValue.toUpperCase();
					if( lvArray.indexOf( lvAttributeValue ) == -1 )
						lvArray.push( lvAttributeValue );
				}
				if( lvArray.length > 1 ) {
					lvArray.sort(avArraySortArgument0, avArraySortArgument1);
					
					if( avPutEmptiesAtBottom ) {
						if( lvArray[0] == "" )
							lvArray.push( lvArray.shift() );
					}
				}
				var lvXmlList:XMLList = new XMLList();
				for each( lvAttributeValue in lvArray ) {
					for each( lvXml in avXml.children() ) {
						var lvXmlAttributeValue:String = lvXml.attribute( avAttributeName );
						if( lvSortCaseInsensitive )
							lvXmlAttributeValue = lvXmlAttributeValue.toUpperCase();
						if( lvXmlAttributeValue == lvAttributeValue )
							lvXmlList += lvXml;
							
					}	
				}
				avXml.setChildren( lvXmlList );
			}
			for each( var lvXmlChild:XML in avXml.children() ) {
				sortXmlAttribute(lvXmlChild, avAttributeName, avPutEmptiesAtBottom, avArraySortArgument0, avArraySortArgument1);
			}
		}
	}
}