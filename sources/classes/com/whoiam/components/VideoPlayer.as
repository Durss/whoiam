package com.whoiam.components {
	import by.blooddy.crypto.MD5;

	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.video.NetStreamClient;
	import com.nurun.utils.video.events.NetStreamEvent;

	import flash.display.Sprite;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.ByteArray;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	/**
	 * 
	 * @author durss
	 * @date 8 févr. 2013;
	 */
	public class VideoPlayer extends Sprite {
		private var _video:Video;
		private var _nc:NetConnection;
		private var _ns:NetStream;
		private var _client:NetStreamClient;
		private var _file:File;
		private var _interval:uint;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>VideoPlayer</code>.
		 */

		public function VideoPlayer() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		public function play(data:ByteArray):void {
			///Video can only be read from a physic file.
			//So we upload it to the hard drive before playing it.
			var file:File = File.applicationStorageDirectory.resolvePath(MD5.hash(new Date().getTime()+"_"+Math.random().toString()));
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.WRITE);
			fs.writeBytes(data);
			fs.close();
			
			_file = file;
			_video.clear();
			_ns.play(file.nativePath);
			clearInterval(_interval);
			_interval = setInterval(checkEnd, 100);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_client = new NetStreamClient();
			_video = addChild(new Video()) as Video;
			_nc = new NetConnection();
			_nc.connect(null);
			_ns = new NetStream(_nc);
			_ns.client = _client;
			_video.attachNetStream(_ns);
			
			_client.addEventListener(NetStreamEvent.METADATA, metadataHandler);
		}

		private function metadataHandler(event:NetStreamEvent):void {
			var ratio:Number = Math.max(stage.stageWidth/_client.width, stage.stageHeight/_client.height);
			scaleX = scaleY = ratio;
			PosUtils.centerInStage(this);
		}

		private function checkEnd():void {
			visible = _ns.time > 0;
			if( _ns.time > _client.duration - .5 && _ns.time > 0 && _client.duration > 0 && !isNaN(_client.duration) ) {
				_ns.close();
				_video.clear();
				visible = false;
				clearInterval(_interval);
				if(_file.exists) {
					setTimeout(_file.deleteFile, 3000);//Let time to freed the file
				}
			}
		}
		
	}
}