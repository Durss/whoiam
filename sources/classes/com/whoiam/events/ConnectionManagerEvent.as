package com.whoiam.events {
	import flash.events.Event;
	
	/**
	 * Event fired by ConnectionManager
	 * 
	 * @author durss
	 * @date 17 juil. 2012;
	 */
	public class ConnectionManagerEvent extends Event {
		
		public static const ON_DATA:String = "onConnectionData";
		public static const ON_CONNECT:String = "onConnectionConnect";
		public static const ON_USER_CONNECT:String = "onConnectionUserConnect";
		public static const ON_USER_DISCONNECT:String = "onConnectionUserDisonnect";
		public static const ON_USER_UPDATE:String = "onConnectionUserUpdate";

		private var _data:Object;
		private var _action:String;
		private var _peerID:String;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ConnectionManagerEvent</code>.
		 */
		public function ConnectionManagerEvent(type:String, action:String, data:Object, peerID:String = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			_action = action;
			_data = data;
			_peerID = peerID;
			super(type, bubbles, cancelable);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the received data
		 */
		public function get data():Object { return _data; }
		
		/**
		 * Gets the action type
		 */
		public function get action():String { return _action; }
		
		/**
		 * Gets the peer's ID that send the data
		 */
		public function get peerID():String { return _peerID; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Makes a clone of the event object.
		 */
		override public function clone():Event {
			return new ConnectionManagerEvent(type, action, data, _peerID, bubbles, cancelable);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}