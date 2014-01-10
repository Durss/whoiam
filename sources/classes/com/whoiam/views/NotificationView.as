package com.whoiam.views {
	import gs.TweenLite;

	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.projectcocoon.p2p.vo.ClientVO;
	import com.whoiam.events.ConnectionManagerEvent;
	import com.whoiam.model.Model;
	import com.whoiam.p2p.ConnectionManager;

	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.Screen;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	/**
	 * Displays the users connections notifications.
	 * 
	 * @author durss
	 * @date 11 févr. 2013;
	 */
	public class NotificationView extends AbstractView {
		
		private var _window:NativeWindow;
		private var _tf:CssTextField;
		private var _usersJustConnected:Vector.<ClientVO>;
		private var _holder:Sprite;
		private var _timeout:uint;
		private var _ready:Boolean;
		private var _listening:Boolean;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>NotificationView</code>.
		 */
		public function NotificationView() {
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Called on model's update
		 */
		override public function update(event:IModelEvent):void {
			var model:Model = event.model as Model;
			if(!_ready && !model.controledMode && !model.mobileMode) {
				_ready = true;
				initialize();
			}
			
			if(_ready) {
				if(model.controledMode) {
					if(_listening)  ConnectionManager.getInstance().removeEventListener(ConnectionManagerEvent.ON_USER_UPDATE, userConnectHandler);
					_listening = false;
				}else{
					if(!_listening) ConnectionManager.getInstance().addEventListener(ConnectionManagerEvent.ON_USER_UPDATE, userConnectHandler);					
					_listening = true;
				}
			}
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			var opts:NativeWindowInitOptions = new NativeWindowInitOptions();
			opts.type = NativeWindowType.LIGHTWEIGHT;
			opts.transparent = true;
			opts.systemChrome = NativeWindowSystemChrome.NONE;
			opts.resizable = false;
			opts.maximizable = false;
			opts.minimizable = false;
			_window = new NativeWindow(opts);
			_window.stage.scaleMode = StageScaleMode.NO_SCALE;
			_window.stage.align = StageAlign.TOP_LEFT;
			
			_usersJustConnected = new Vector.<ClientVO>();
			_holder	= _window.stage.addChild(new Sprite()) as Sprite;
			_tf		= _holder.addChild(new CssTextField("notification")) as CssTextField;
			
			
			_holder.filters = [new DropShadowFilter(5,135,0,.3,10,10,1,3)];
			_holder.y = 300;
		}
		 
		/**
		 * Called when a user connects
		 */
		private function userConnectHandler(event:ConnectionManagerEvent):void {
			var vo:ClientVO = event.data as ClientVO;
			
			clearTimeout(_timeout);
			_usersJustConnected.push(vo);
			
			var i:int, len:int, txt:String, namesDone:Object;
			len = _usersJustConnected.length;
			txt = "";
			namesDone = {};
			for(i = 0; i < len; ++i) {
				if(namesDone[ _usersJustConnected[i].clientName ] === true) continue;
				txt += "• " + _usersJustConnected[i].clientName;
				namesDone[ _usersJustConnected[i].clientName ] = true;
				if(i < len - 1) txt += "<br />";
			}
			
			_tf.text = Label.getLabel("notification").replace(/\{USERS\}/gi, txt);
			_tf.width = 300;
			
			var margin:int = 10;
			
			_window.stage.addChild(_holder);
			_holder.graphics.beginFill(0xffffff, 1);
			_holder.graphics.drawRect(0, 0, _tf.width + margin * 2, _tf.height + margin * 2);
			_holder.graphics.endFill();
			_tf.x = _tf.y = margin;
			
			var b:Rectangle = Screen.mainScreen.bounds;
			_window.bounds = new Rectangle(	0, 0, _holder.width + 40, _holder.height + 40);
			_window.x = b.x + b.width - _window.width;
			_window.y = b.y + b.height - _window.height - 20;
			_window.activate();
			
			_holder.x = 20;//Offset to see the shadow at left.
			
			TweenLite.killTweensOf(_holder);
			TweenLite.to(_holder, .5, {y:20});//Not to 0 or the shadow would be cut.
			_timeout = setTimeout(close, 4000);
		}
		
		/**
		 * Closes the notification
		 */
		private function close():void {
			_usersJustConnected = new Vector.<ClientVO>();
			TweenLite.killTweensOf(_holder);
			TweenLite.to(_holder, .5, {y:_window.height + 20, removeChild:true});
		}
		
	}
}