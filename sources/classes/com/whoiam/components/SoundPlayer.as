package com.whoiam.components {
	import flash.utils.setTimeout;
	import flash.events.Event;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	import by.blooddy.crypto.MD5;

	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.media.Sound;
	import flash.utils.ByteArray;
	
	/**
	 * 
	 * @author durss
	 * @date 8 févr. 2013;
	 */
	public class SoundPlayer {
		private var _sound:Sound;
		private var _channel:SoundChannel;
		private var _file:File;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>SoundPlayer</code>.
		 */
		public function SoundPlayer() {
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Initialize the class.
		 */
		public function play(data:ByteArray):void {
			///Video can only be read from a physic file.
			//So we upload it to the hard drive before playing it.
			_file = File.applicationStorageDirectory.resolvePath(MD5.hash(new Date().getTime()+"_"+Math.random().toString()));
			var fs:FileStream = new FileStream();
			fs.open(_file, FileMode.WRITE);
			fs.writeBytes(data);
			fs.close();
			
			_sound = new Sound(new URLRequest(_file.nativePath));
			_channel = _sound.play();
			_channel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
		/**
		 * Called when sound completes
		 */
		private function soundCompleteHandler(event:Event):void {
			try {
				_sound.close();
				_channel.stop();
			}catch(error:Error) { };
			
			setTimeout(_file.deleteFile, 3000);//Let time to freed the file
		}
		
	}
}