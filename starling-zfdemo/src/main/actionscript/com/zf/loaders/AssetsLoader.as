﻿package com.zf.loaders{	import com.greensock.events.LoaderEvent;	import com.greensock.loading.DataLoader;	import com.greensock.loading.ImageLoader;	import com.greensock.loading.LoaderMax;	import com.greensock.loading.MP3Loader;	import com.greensock.loading.XMLLoader;	import com.greensock.loading.display.ContentDisplay;	import com.zf.core.Config;	import com.zf.utils.FileUtils;	import org.osflash.signals.Signal;
		public class AssetsLoader {				private var className:String = 'AssetsLoader';				private static var instance				: AssetsLoader;		private static var allowInstantiation	: Boolean;				public var queue:LoaderMax;				/**		 * holds an array of objects		 */		private var callbackArray:Array;						public var onProgress:Signal;		public var onComplete:Signal;				/***		 * Gets the singleton instance of ZFLoader or creates a new one		 */		public static function getInstance():AssetsLoader {			if (instance == null) {				allowInstantiation = true;								instance = new AssetsLoader();								allowInstantiation = false;			}			return instance;		}				public function AssetsLoader() {			if (!allowInstantiation) {				throw new Error("Error: Instantiation failed: Use ZFLoader.getInstance() instead of new.");			} else {				initQueue();			}		}				private function initQueue():void  {			onProgress = new Signal();			onComplete = new Signal();			queue =  new LoaderMax({name:"mainQueue", 								   onProgress:onProgressHandler, 								   onComplete:onCompleteHandler, 								   onError:onErrorHandler,								   autoLoad:true								   });			callbackArray = [];		}				public function addToLoad(path:String, cb:Function, id:String = '', //								  includeAssetPath:Boolean = true, //								  startQueueLoad:Boolean = true, //								  opts:Object = null):void  {			var fileName:String = FileUtils.getFilenameFromPath(path);			var ext:String = FileUtils.getExtFromFilename(path);			// if id was not supplied, use the filename minus extension			if(id == '') {				id = fileName;			}			// Set up the fullPath for the asset			var fullPath:String = FileUtils.getFullPath(path, includeAssetPath, ext);			var useRawContent:Boolean = false;			if(ext == Config.IMG_JPG 				|| ext == Config.IMG_GIF 				|| ext == Config.IMG_PNG) {				useRawContent=true;			}						// handle callback queue			callbackArray.push({ 'fileName': fileName, 							   	 'cb': cb,								 'id': id,								 'useRawContent': useRawContent,								 'options': opts							  });							  			Config.log(className, 'addToLoad', "Adding callback function for " + path + " to callBackArray index: " + (callbackArray.length - 1 ).toString());			Config.log(className, 'addToLoad', "FileName: " + fileName + " || FullPath: " + fullPath + " || ext: " + ext);						switch(ext) {				// EXTENSIONS				case Config.DATA_XML:				case Config.DATA_PEX:					queue.append(new XMLLoader(fullPath, {'name':id}));					break;								case Config.IMG_JPG:				case Config.IMG_PNG:				case Config.IMG_GIF:					queue.append(new ImageLoader(fullPath, {'name':id}));					break;								case Config.DATA_JSON:				case Config.DATA_FNT:					queue.append(new DataLoader(fullPath, {'name':id}));					break;								case Config.DATA_MP3:					queue.append(new MP3Loader(fullPath, {'name':id, 'autoPlay': false}));					break;			}						if(startQueueLoad) {				queue.load();			}		}				public function addCallbackToQueueEvent(eventName:String, callback:Function):void {			queue.addEventListener(eventName, callback);		}				public function removeCallbackToQueueEvent(eventName:String, callback:Function):void {			queue.removeEventListener(eventName, callback);		}				/***		 * Process data and make sure loaded items get sent back to proper callbacks		 **/		public function onCompleteHandler(event:LoaderEvent):void {			Config.log(className, 'onCompleteHandler', "Beginning to process " + event.target);						// Array of Objects used to temporarily store things that have not fully been loaded yet 			// and are not ready for callback			var nextPassArray:Array = [];			// item will hold the data from callBackArray that we're processing			var item:Object;						while(callbackArray.length > 0)  {				// remove the item from the array so we dont try to process it again				// save it in item so we can process it there				item = callbackArray.shift();								Config.log(className, 'onCompleteHandler', "Processing fileName: " + item.id);								// holds the content we've just loaded. may be an image (ContentDisplay) or xml or other data type				var contentData:* = queue.getContent(item.id);								// if contentData has not loaded yet, save the item and continue				if((contentData is ContentDisplay && contentData.rawContent == undefined) || contentData == undefined) 				{					Config.log(className, 'onCompleteHandler', "Moving " + item.id + " to the Next Pass");					nextPassArray.push(item);				} 				else 				{					var data:*;					if(item.useRawContent) {						data = contentData.rawContent;					} else {						data = contentData;					}					item.cb(new CallBackObject(item.id, data, item.options));				}			}			callbackArray = nextPassArray;						if(callbackArray.length == 0) {				onComplete.dispatch();				Config.log(className, 'onCompleteHandler', event.target + " is complete!");			}		}		public function onProgressHandler(event:LoaderEvent):void {    		Config.log(className, 'onProgressHandler', "progress: " + event.target.progress);			onProgress.dispatch(event.target.progress);		}		public function onErrorHandler(event:LoaderEvent):void {			Config.logError(className, 'onErrorHandler', "error occured with " + event.target + ": " + event.text);		}	}}