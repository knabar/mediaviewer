package org.mdid.mediaviewer.vo
{
	import flash.display.BitmapData;
	
	public class Slide
	{
		private var _imageURL:String;
		private var _thumbURL:String;
		private var _slideID:String;
		private var _imageID:String;
		private var _collectionID:String;
		private var _imageFilename:String;
		private var _thumbFilename:String;
		private var _slideAnnotation:String;
		private var _imageNotes:String;
		public var catalogData:Array = new Array();
		public var catalogDataAsHtmlBlock:String;
		public var notesDataAsHtmlBlock:String;
		public var collection:String;
		public var title:String
		public var imageIsCached:Boolean = false;
		public var imageIsValid:Boolean = false;
		public var thumbBitmap:BitmapData;
		
		
		public function get thumbFilename():String {
			return _thumbFilename;
		}
		public function get thumbURL():String {
			return _thumbURL;
		}
		public function get imageURL():String {
			return _imageURL;
		}
		public function get slideID():String {
			return _slideID;
		}
		public function get imageID():String {
			return _imageID;
		}
		public function get collectionID():String {
			return _collectionID;
		}
		public function get imageFilename():String {
			return _imageFilename;
		}
		
		public function Slide(theImageURL:String, theSlideID:String, theImageID:String, theCollectionID:String, theImageFilename:String, theSlideAnnotation:String, theImageNotes:String, theCatalogData:XMLList, theThumbUrl:String=""):void {
			_imageURL = theImageURL;
			if (GeneralFactory.getInstance().mdidversion == GeneralFactory.MDID2) {
				var pattern:RegExp = /format=\w/;
				_thumbURL = _imageURL.replace(pattern, "format=T");
			} else {
				_thumbURL = theThumbUrl;
			}
			_slideID = theSlideID;
			_imageID = theImageID;
			_collectionID = theCollectionID;
			_imageFilename = theImageFilename;
			_thumbFilename = theImageFilename.substr(0, theImageFilename.lastIndexOf(".")) + "_thumb" + theImageFilename.substring(theImageFilename.lastIndexOf("."));
			_slideAnnotation = theSlideAnnotation;
			_imageNotes = theImageNotes;
			if (_slideAnnotation != null && _slideAnnotation.length > 0) {
				this.notesDataAsHtmlBlock = "<P><b>Note:</b> " + _slideAnnotation + "</P>";
			}
			if (_imageNotes != null && _imageNotes.length > 0) {
					this.notesDataAsHtmlBlock += "<P><b>Note:</b> " + _imageNotes + "</P>";
			}
			for each(var item:Object in theCatalogData) {
				if (item.@name.toString().toLowerCase() == "collection") {
					collection = item.toString();
				} else if (item.@name.toString().toLowerCase() == "title") {
					title = item.toString();
				} else {
					var o:Object = new Object();
					o.name = item.@name;
					o.value = item.toString();
					this.catalogData.push(o);
				}
			}
			this.catalogDataAsHtmlBlock = "<P>";
			this.catalogDataAsHtmlBlock += "<B>Title: </B>";
			this.catalogDataAsHtmlBlock += (title != null && title.length > 0) ? title : "N/A";
			this.catalogDataAsHtmlBlock += "</P>";
			if (GeneralFactory.getInstance().mdidversion == GeneralFactory.MDID2) {
				this.catalogDataAsHtmlBlock += "<P>";
				this.catalogDataAsHtmlBlock += "<B>Collection: </B>";
				this.catalogDataAsHtmlBlock += (collection != null && collection.length > 0) ? collection : "N/A";
				this.catalogDataAsHtmlBlock += "</P>";
			}
			for each(var thing:Object in catalogData) {
				this.catalogDataAsHtmlBlock += "<P>";
				this.catalogDataAsHtmlBlock += "<B>" + thing.name + ": </B>";
				this.catalogDataAsHtmlBlock += thing.value.toString().length > 0 ? thing.value.toString() : "N/A";
				this.catalogDataAsHtmlBlock += "</P>";
			}
		}
	}
}