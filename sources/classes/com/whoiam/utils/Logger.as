package com.whoiam.utils {
	import com.nurun.structure.environnement.configuration.Config;
	import flash.filesystem.FileMode;
	import flash.errors.IllegalOperationError;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	
	
	/**
	 * Singleton Logger
	 * 
	 * @author francois.dursus
	 * @date 4 avr. 2014;
	 */
	public class Logger {
		
		private static var _instance:Logger;
		private var _file:File;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Logger</code>.
		 */
		public function Logger(enforcer:SingletonEnforcer) {
			if(enforcer == null) {
				throw new IllegalOperationError("A singleton can't be instanciated. Use static accessor 'getInstance()'!");
			}
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Singleton instance getter.
		 */
		public static function getInstance():Logger {
			if(_instance == null)_instance = new  Logger(new SingletonEnforcer());
			return _instance;	
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		public function log(value:String):void {
			if(Config.getBooleanVariable('log')) {
				var fileStream : FileStream = new FileStream ();
			    fileStream.open (_file, FileMode.APPEND);
			    fileStream.writeMultiByte (value + "\r\n", File.systemCharset);
			    fileStream.close();
			}else{
				trace(value);
			}
		}
		


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_file = File.desktopDirectory.resolvePath('wim.log');
		}
		
	}
}

internal class SingletonEnforcer{}