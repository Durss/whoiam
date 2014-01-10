package com.whoiam.p2p {
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.utils.math.MathUtils;
	import com.projectcocoon.p2p.LocalNetworkDiscovery;
	import com.projectcocoon.p2p.events.ClientEvent;
	import com.projectcocoon.p2p.events.GroupEvent;
	import com.projectcocoon.p2p.events.MessageEvent;
	import com.projectcocoon.p2p.events.ObjectEvent;
	import com.projectcocoon.p2p.vo.ClientVO;
	import com.projectcocoon.p2p.vo.ObjectMetadataVO;
	import com.whoiam.events.ConnectionManagerEvent;

	import flash.desktop.NativeApplication;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;


	
	[Event(name="onConnectionData", type="com.whoiam.events.ConnectionManagerEvent")]
	[Event(name="onConnectionConnect", type="com.whoiam.events.ConnectionManagerEvent")]
	[Event(name="onConnectionUserConnect", type="com.whoiam.events.ConnectionManagerEvent")]
	[Event(name="onConnectionUserDisonnect", type="com.whoiam.events.ConnectionManagerEvent")]
	
	
	/**
	 * Singleton ConnectionManager
	 * 
	 * @author durss
	 * @date 17 juil. 2012;
	 */
	public class ConnectionManager extends EventDispatcher{
		
		private static var _instance:ConnectionManager;
		private var _connection:LocalNetworkDiscovery;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ConnectionManager</code>.
		 */
		public function ConnectionManager(enforcer:SingletonEnforcer) {
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
		public static function getInstance():ConnectionManager {
			if(_instance == null)_instance = new  ConnectionManager(new SingletonEnforcer());
			return _instance;	
		}
		
		/**
		 * Gets the connected clients
		 */
		public function get clients():Vector.<ClientVO> {
			var i:int, len:int;
			var res:Vector.<ClientVO> = new Vector.<ClientVO>();
			len = _connection.clients.length;
			for(i = 0; i < len; ++i) {
				if( !/^CONTROLER_.*/.test(_connection.clients[i].clientName) ) {
					res.push( _connection.clients[i] );
				}
			}
			return res;
		}
		



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Initialize the class.
		 */
		public function connect(name:String = null):void {
			_connection = new LocalNetworkDiscovery();
			_connection.autoConnect = true;
			_connection.groupName = Config.getVariable("p2PGroupName");
			_connection.clientName = (name != null)? name : "CONTROLER_"+(MathUtils.randomNumberFromRange(1000000, 9999999, Math.round));
			_connection.addEventListener(ClientEvent.CLIENT_ADDED, clientAddedHandler);
			_connection.addEventListener(ClientEvent.CLIENT_UPDATE, clientUpdateHandler);
			_connection.addEventListener(ClientEvent.CLIENT_REMOVED, clientRemovedHandler);
			_connection.addEventListener(MessageEvent.DATA_RECEIVED, dataReceivedHandler);
			_connection.addEventListener(ObjectEvent.OBJECT_COMPLETE, byteArrayReceivedHandler);
			_connection.addEventListener(ObjectEvent.OBJECT_ANNOUNCED, objectAnnouncedHandler);
			_connection.addEventListener(GroupEvent.GROUP_CONNECTED, connectHandler);
			NativeApplication.nativeApplication.addEventListener(Event.NETWORK_CHANGE, networkConnectivityChangeHandler);
		}
		
		/**
		 * Disconnects from the P2P session
		 */
		public function disconnect():void {
			_connection.close();
		}

		
		/**
		 * Called when connectivity changes. Try to reconnect
		 * 
		 */
		private function networkConnectivityChangeHandler(event:Event):void {
			_connection.connect();
		}
		
		/**
		 * Sends a data to all neightboors.
		 */
		public function send(actionType:String, data:Object = null, fireToSelf:Boolean = false):void {
			var obj:Object = {};
			obj["d"] = data;
			obj["a"] = actionType;
//			_connection.sendMessageToAll(obj);
			
			//Send directly to all the connected peers.
			//sendMessageToAll uses "post" method, which is far more slow than the "sendToNeighbor"
			//used by the sendMessageToClient. That's why we use this.
			var i:int, len:int;
			len = _connection.clients.length;
			for(i = 0; i < len; ++i) {
				_connection.sendMessageToClient(obj, _connection.clients[i].groupID);
			}
			if(fireToSelf) {
				dispatchEvent(new ConnectionManagerEvent(ConnectionManagerEvent.ON_DATA, actionType, data));
			}
		}
		
		/**
		 * Sends a message to a specific peer.
		 */
		public function sendToPeer(groupID:String, action:String, data:Object):void {
			var obj:Object = {};
			obj["d"] = data;
			obj["a"] = action;
			_connection.sendMessageToClient(obj, groupID);
		}
		
		/**
		 * Shares a file over the network.
		 */
		public function shareFile(groupID:String, actionType:String, data:ByteArray, fileName:String):void {
			//Adds action type to the beginning of the byte array
			data.position = 0;
			var ba:ByteArray = new ByteArray();
			ba.writeUTF(actionType);//No need to store the string's length, writeUTF already does it.
			ba.writeUTF(fileName);//No need to store the string's length, writeUTF already does it.
			data.readBytes(ba, ba.length, data.length);
			_connection.shareWithClient(ba, groupID);
		}
		
		/**
		 * Restarts the connection
		 */
		public function start():void {
			_connection.connect();
		}
		
		/**
		 * Stops the connection
		 */
		public function stop():void {
			_connection.close();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Called when connection starts
		 */
		private function connectHandler(data:Object):void {
			dispatchEvent(new ConnectionManagerEvent(ConnectionManagerEvent.ON_CONNECT, null, data));
		}
		
		/**
		 * Called when a user connects
		 */
		private function clientAddedHandler(event:ClientEvent):void {
			var id:String = event.client.groupID;
			dispatchEvent(new ConnectionManagerEvent(ConnectionManagerEvent.ON_USER_CONNECT, null, id, id));
		}
		
		/**
		 * Called when a client is updated
		 */
		private function clientUpdateHandler(event:ClientEvent):void {
			var id:String = event.client.groupID;
			if(event.client == null || /^CONTROLER_.*/.test(event.client.clientName) ) return;
			dispatchEvent(new ConnectionManagerEvent(ConnectionManagerEvent.ON_USER_UPDATE, null, event.client, id));
		}
		
		/**
		 * Called when a user disconnects
		 */
		private function clientRemovedHandler(event:ClientEvent):void {
			var id:String = event.client.groupID;
			dispatchEvent(new ConnectionManagerEvent(ConnectionManagerEvent.ON_USER_DISCONNECT, null, id, id));
		}
		
		/**
		 * Called when a data is recieved
		 */
		private function dataReceivedHandler(event:MessageEvent):void {
			var peerId:String = event.message.client.groupID;
			var data:Object = event.message.data;
			dispatchEvent(new ConnectionManagerEvent(ConnectionManagerEvent.ON_DATA, data["a"], data["d"], peerId));
		}
		
		/**
		 * Called when a byte array is received.
		 */
		private function byteArrayReceivedHandler(event:ObjectEvent):void {
			var i:int, len:int, ba:ByteArray;
			len = _connection.receivedObjects.length;
			for(i = 0; i < len; ++i) {
				var obj:ObjectMetadataVO = _connection.receivedObjects.pop();
				if(!obj.isComplete) continue;
				if(obj.object is ByteArray) {
					ba = obj.object as ByteArray;
					var actionType:String = ba.readUTF();
					var fileName:String = ba.readUTF();
					var file:ByteArray = new ByteArray();
					ba.readBytes(file, 0, ba.bytesAvailable);
					dispatchEvent(new ConnectionManagerEvent(ConnectionManagerEvent.ON_DATA, actionType, {name:fileName, data:file}));
				}
			}
		}
		
		/**
		 * Called when a new object announced.
		 */
		private function objectAnnouncedHandler(event:ObjectEvent):void {
			_connection.requestObject(event.metadata);
		}
		
	}
}

internal class SingletonEnforcer{}