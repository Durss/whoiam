package com.whoiam.mobile {
	import gs.plugins.RemoveChildPlugin;
	import gs.plugins.TweenPlugin;

	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.EnvironnementManager;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.text.CssManager;
	import com.whoiam.controler.FrontControler;
	import com.whoiam.model.Model;
	import com.whoiam.views.ControlerView;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filters.DropShadowFilter;
	import flash.system.Capabilities;

	/**
	 * Bootstrap class of the application.
	 * Must be set as the main class for the flex sdk compiler
	 * but actually the real bootstrap class will be the factoryClass
	 * designated in the metadata instruction.
	 * 
	 * @author francois.dursus
	 * @date 26 févr. 2013;
	 */
	 
	[SWF(width="800", height="600", backgroundColor="0xFFFFFF", frameRate="31")]
	public class MobileApp extends Sprite {
		private var _env:EnvironnementManager;
		private var _tf:CssTextField;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Application</code>.
		 */
		public function MobileApp() {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			var lang:String = Capabilities.language;
			var url:String = "xml/labels_"+Capabilities.language+".xml";
			if (!File.applicationDirectory.resolvePath(url).exists) lang = "en";
			
			_env = new EnvironnementManager();
			_env.addVariables({lang:lang});
			_env.initialise("xml/config.xml");
			_env.addEventListener(IOErrorEvent.IO_ERROR, initErrorHandler);
			_env.addEventListener(Event.COMPLETE, initialize);
			
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
			TweenPlugin.activate([RemoveChildPlugin]);
			
			var model:Model = new Model();
			FrontControler.getInstance().initialize(model);
			ViewLocator.getInstance().initialise(model);

			var view:DisplayObject = addChild(new ControlerView());
			view.scaleX = view.scaleY = 2;
			
			model.start(true);
			
			FrontControler.getInstance().init(false);
		}
		
		/**
		 * Called when init failed
		 */
		private function initErrorHandler(event:IOErrorEvent):void {
			CssManager.getInstance().setCss(".debug { font-family:Arial; font-size:14px; color:#cc0000; flash-glow:[1.2,100,ffffff]; flash-bitmap:true; }");
			if(_tf == null) {
				_tf = addChild(new CssTextField("debug")) as CssTextField;
				_tf.filters = [new DropShadowFilter(0,0,0xffffff,1,2,2,10,3)];
				_tf.selectable = true;
			}
			_tf.text = "<font size='26'><b>Oops... an error has occured :</b></font><br/>" + event.text;
			_tf.width = stage.stageWidth;
			PosUtils.centerIn(_tf, stage);
		}
		
	}
}