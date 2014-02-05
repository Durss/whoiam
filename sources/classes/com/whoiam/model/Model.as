package com.whoiam.model {
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.structure.mvc.model.IModel;
	import com.nurun.structure.mvc.model.events.ModelEvent;
	import com.nurun.utils.commands.BrowseForFileCmd;
	import com.projectcocoon.p2p.vo.ClientVO;
	import com.whoiam.events.ConnectionManagerEvent;
	import com.whoiam.p2p.ConnectionManager;
	import com.whoiam.vo.ActionType;

	import flash.desktop.NativeApplication;
	import flash.events.EventDispatcher;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;

	
	/**
	 * 
	 * @author durss
	 * @date 6 févr. 2013;
	 */
	public class Model extends EventDispatcher implements IModel {
		
		private var _controledMode:Boolean;
		private var _connected:Boolean;
		private var _so:SharedObject;
		private var _browseCmd:BrowseForFileCmd;
		private var _fileSendTarget:ClientVO;
		private var _mobileMode:Boolean;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Model</code>.
		 */

		public function Model() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets if the user is controled or controler.
		 */
		public function get controledMode():Boolean { return _controledMode; }
		
		/**
		 * Gets if we are connected to the groupe ready to give or get orders.
		 */
		public function get connected():Boolean { return _connected; }
		
		/**
		 * Gets if we are running on mobile platform
		 */
		public function get mobileMode():Boolean { return _mobileMode; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Starts the application
		 */
		public function start(mobileMode:Boolean = false):void {
			_mobileMode = mobileMode;
			if (_so.data["userName"] != undefined) {
				init(true, _so.data["userName"]);
			}else{
				update();
			}
		}
		
		/**
		 * Initializes the mode
		 */
		public function init(controledMode:Boolean, name:String = null):void {
			if(name != null) {
				_so.data["userName"] = name;
				_so.flush();
			}
			_controledMode = controledMode;
			
			try {
				if (NativeApplication.supportsStartAtLogin) {
					//Forces app to launch at startup if controled mode
					NativeApplication.nativeApplication.startAtLogin = _controledMode;
				}
			}catch(error:Error) {
				//Doesn't work in ADL
			}
			ConnectionManager.getInstance().connect(name);
		}
		
		/**
		 * Sends an action to a client
		 */
		public function sendActionTo(action:String, client:ClientVO, data:* = null):void {
			ConnectionManager.getInstance().sendToPeer(client.groupID, action, data);
		}
		
		/**
		 * Sends a file to a peer.
		 */
		public function sendFile(peer:ClientVO):void {
			_fileSendTarget = peer;
			_browseCmd.execute();
		}
		
		/**
		 * Resets the user's victim's mode
		 */
		public function reset():void {
			_so.clear();
			_controledMode = false;
			_connected = false;
			ConnectionManager.getInstance().disconnect();
			try {
				if (NativeApplication.supportsStartAtLogin) {
					//Remove auto launch at startup
					NativeApplication.nativeApplication.startAtLogin = false;
				}
			}catch(error:Error) {
				//Doesn't work in ADL
			}
			update();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_so = SharedObject.getLocal("_whoiam");
//			_so.clear();
			
			_browseCmd = new BrowseForFileCmd();
			_browseCmd.addEventListener(CommandEvent.COMPLETE, browseCompleteHandler);
			
			ConnectionManager.getInstance().addEventListener(ConnectionManagerEvent.ON_CONNECT, connectHandler);
		}
		
		/**
		 * Called when a file is selected
		 */
		private function browseCompleteHandler(event:CommandEvent):void {
			ConnectionManager.getInstance().shareFile(_fileSendTarget.groupID, ActionType.FILE, event.data as ByteArray, _browseCmd.fileName);
		}
		
		/**
		 * Called when connected to P2P group
		 */
		private function connectHandler(event:ConnectionManagerEvent):void {
			_connected = true;
			update();
		}
		
		/**
		 * Fires an update to the views
		 */
		private function update():void {
			dispatchEvent(new ModelEvent(ModelEvent.UPDATE, this));
		}
		
	}
}