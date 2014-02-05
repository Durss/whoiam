package com.whoiam {
	import gs.plugins.RemoveChildPlugin;
	import gs.plugins.TweenPlugin;

	import com.nurun.structure.mvc.model.events.ModelEvent;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.whoiam.controler.FrontControler;
	import com.whoiam.model.Model;
	import com.whoiam.views.ControledView;
	import com.whoiam.views.ControlerView;
	import com.whoiam.views.NotificationView;
	import com.whoiam.views.StartView;

	import flash.display.MovieClip;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * Bootstrap class of the application.
	 * Must be set as the main class for the flex sdk compiler
	 * but actually the real bootstrap class will be the factoryClass
	 * designated in the metadata instruction.
	 * 
	 * @author durss
	 * @date 6 févr. 2013;
	 */
	 
	[SWF(width="1024", height="600", backgroundColor="0xFFFFFF", frameRate="31")]
	[Frame(factoryClass="com.whoiam.ApplicationLoader")]
	public class Application extends MovieClip {
		private var _mask:Shape;
		private var _window:NativeWindow;
		private var _holder:Sprite;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Application</code>.
		 */
		public function Application() {
			addEventListener(Event.ADDED_TO_STAGE, initialize);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			
			TweenPlugin.activate([RemoveChildPlugin]);
			
			var model:Model = new Model();
			FrontControler.getInstance().initialize(model);
			ViewLocator.getInstance().initialise(model);
			
			model.addEventListener(ModelEvent.UPDATE, modelUpdateHandler);

			var options:NativeWindowInitOptions = new NativeWindowInitOptions();
			options.minimizable = false;
			options.resizable = false;
			options.systemChrome = NativeWindowSystemChrome.NONE;
			options.transparent = true;
			options.type = NativeWindowType.UTILITY;
			_window = new NativeWindow(options);
			_window.stage.scaleMode = StageScaleMode.NO_SCALE;
			_window.stage.align = StageAlign.TOP_LEFT;
			_window.activate();
			
			_holder = new Sprite();
			
			_holder.addChild(new StartView());
			_holder.addChild(new ControlerView());
			_holder.addChild(new ControledView());
			_holder.addChild(new NotificationView());
			
			_window.stage.addChild(_holder);
//			_window.stage.addEventListener(Event.ENTER_FRAME, mouseMoveHandler);
			
			model.start();
		}

		private function modelUpdateHandler(event:ModelEvent):void {
			return;
			
			//The following provides a way to get the mouse reacting depending on what's behind the app
			//by creating a "hole" in the application's rendering at the mouse's position.
			//But it doesn't work well as mouse move is only catched when mouse comes over the layer.
			//So the hole is updated only when mouse goes out of it. This makes the mouse's state
			//blinking when moving it.
			var model:Model = event.model as Model;
			if(model.controledMode) {
				_mask = addChild(new Shape()) as Shape;
				_holder.mask = _mask;
				_window.stage.addChild(_mask);
				_window.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
				model.removeEventListener(ModelEvent.UPDATE, modelUpdateHandler);
				mouseMoveHandler();
			}
		}

		private function mouseMoveHandler(event:Event = null):void {
			var margin:int = 4;
			var h:int = _window.stage.mouseY - margin;
			_mask.graphics.clear();
			_mask.graphics.beginFill(0xff0000, 1);
			_mask.graphics.drawRect(0, 0, _window.stage.stageWidth, h);
			_mask.graphics.drawRect(0, _window.stage.mouseY + margin, _window.stage.stageWidth, _window.stage.stageHeight - h);
			_mask.graphics.drawRect(0, h, _window.stage.mouseX - margin, margin * 2);
			_mask.graphics.drawRect(_window.stage.mouseX + margin, h, _window.stage.stageWidth - _window.stage.mouseX - margin, margin * 2);
//			_mask.graphics.drawCircle(_window.stage.mouseX, _window.stage.mouseY, 50);
			if(event != null && event is MouseEvent) MouseEvent(event).updateAfterEvent();
		}
		
	}
}