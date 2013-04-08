package com.whoiam.utils {
	import com.nurun.utils.bitmap.BitmapUtils;

	import flash.desktop.NativeApplication;
	import flash.desktop.SystemTrayIcon;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	/**
	 * @author durss
	 */
	public function systrayIconBuild(stage:Stage):SystemTrayIcon {
		if (NativeApplication.supportsSystemTrayIcon) {
			var fs:FileStream = new FileStream();
			var loader:Loader = new Loader();
		    var sysTrayIcon:SystemTrayIcon = NativeApplication.nativeApplication.icon as SystemTrayIcon;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(event:Event) {
				var bmd:BitmapData = Bitmap(LoaderInfo(event.target).loader.content).bitmapData;
				bmd = BitmapUtils.resampleBitmapData(bmd, 16/36);
				NativeApplication.nativeApplication.icon.bitmaps = [bmd];
				var descriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
				var ns:Namespace = descriptor.namespace();
//				var name:String = descriptor.ns::filename[0];
			    sysTrayIcon.tooltip = "Whoiam";//+name;
			    sysTrayIcon.addEventListener(MouseEvent.CLICK, function(event:Event) {
					stage.nativeWindow.activate();
					stage.nativeWindow.orderToFront();
					stage.nativeWindow.alwaysInFront = true;
					stage.nativeWindow.alwaysInFront = false;
				});
			});
			var file:File = File.applicationDirectory.resolvePath("AppIcons/36x36-36.png");
			if(file.exists) {
				loader.load(new URLRequest(File.applicationDirectory.resolvePath("AppIcons/36x36-36.png").url));
			}
			
			return sysTrayIcon;
		}
		return null;
	}
}
