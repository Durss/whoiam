package com.whoiam.components {
	import flash.display.NativeWindow;
	import flash.desktop.NativeApplication;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	
	/**
	 * Displays close/minimize buttons
	 * 
	 * @author Francois
	 * @date 12 févr. 2013;
	 */
	public class NavBar extends Sprite {
		private var _minButton:TButton;
		private var _closeButton:TButton;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>NavBar</code>.
		 */
		public function NavBar() {
			initialize();
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
		private function initialize():void {
			_minButton = addChild(new TButton("-")) as TButton;
			_closeButton = addChild(new TButton("x")) as TButton;
			
			_minButton.width = _minButton.height = 
			_closeButton.width = _closeButton.height = 23;
			
			_closeButton.x = _minButton.width + 5;
			
			addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		/**
		 * Called when a button is clicked to close or minimize all the windows
		 */
		private function clickHandler(event:MouseEvent):void {
			var windows:Array = NativeApplication.nativeApplication.openedWindows;
			var i:int, len:int;
			len = windows.length;
			for(i = 0; i < len; ++i) {
				if(event.target == _closeButton) {
					NativeWindow(windows[i]).close();
				}else{
					if(NativeWindow(windows[i]).visible) {
						NativeWindow(windows[i]).minimize();
					}
				}
			}
		}
		
	}
}