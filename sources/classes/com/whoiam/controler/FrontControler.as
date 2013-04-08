package com.whoiam.controler {
	import com.projectcocoon.p2p.vo.ClientVO;
	import com.whoiam.model.Model;

	import flash.errors.IllegalOperationError;
	
	
	/**
	 * Singleton FrontControler
	 * 
	 * @author durss
	 * @date 6 févr. 2013;
	 */
	public class FrontControler {
		
		private static var _instance:FrontControler;
		private var _model:Model;

		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>FrontControler</code>.
		 */
		public function FrontControler(enforcer:SingletonEnforcer) {
			if(enforcer == null) {
				throw new IllegalOperationError("A singleton can't be instanciated. Use static accessor 'getInstance()'!");
			}
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Singleton instance getter.
		 */
		public static function getInstance():FrontControler {
			if(_instance == null)_instance = new  FrontControler(new SingletonEnforcer());
			return _instance;	
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Initialize the class.
		 */
		public function initialize(model:Model):void {
			_model = model;
		}
		
		/**
		 * Initializes the mode
		 */
		public function init(controledMode:Boolean, name:String = null):void {
			_model.init(controledMode, name);
		}
		
		/**
		 * Sends an action to a client
		 */
		public function sendActionTo(action:String, client:ClientVO, data:* = null):void {
			_model.sendActionTo(action, client, data);
		}
		
		/**
		 * Sends a file to a peer.
		 */
		public function sendFile(peer:ClientVO):void {
			_model.sendFile(peer);
		}
		
		/**
		 * Resets the user's victim's mode
		 */
		public function reset():void {
			_model.reset();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}

internal class SingletonEnforcer{}