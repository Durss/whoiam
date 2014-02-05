package com.whoiam.views {
	import com.nurun.components.form.events.FormComponentEvent;
	import com.nurun.components.invalidator.Validable;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.string.StringUtils;
	import com.whoiam.components.NavBar;
	import com.whoiam.components.TButton;
	import com.whoiam.components.TInput;
	import com.whoiam.controler.FrontControler;
	import com.whoiam.model.Model;
	import com.whoiam.utils.systrayIconBuild;

	import flash.desktop.DockIcon;
	import flash.desktop.NativeApplication;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.Screen;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldType;

	/**
	 * 
	 * @author durss
	 * @date 6 févr. 2013;
	 */
	public class StartView extends AbstractView {
		
		private var _label:CssTextField;
		private var _controledBt:TButton;
		private var _controlerBt:TButton;
		private var _nameInput:TInput;
		private var _ready:Boolean;
		private var _navBar:NavBar;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>StartView</code>.
		 */
		public function StartView() {
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
			visible = !model.connected;
			
			//Enable the buttons back so that if the user is reset, he can click them again
			if(_ready && visible) {
				_controledBt.enabled = _controlerBt.enabled = true;
				_controledBt.spinMode = _controlerBt.spinMode = false;
			}
			
			if(visible && !_ready) {
				_ready = true;
				initialize();
			}
			if(visible) computePositions();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_label = addChild(new CssTextField("homeTitle")) as CssTextField;
			_nameInput = addChild(new TInput(Label.getLabel("defaultNickName"))) as TInput;
			_controledBt = addChild(new TButton(Label.getLabel("controledBt"))) as TButton;
			_controlerBt = addChild(new TButton(Label.getLabel("controlerBt"))) as TButton;
			_navBar = addChild(new NavBar()) as NavBar;
			
			_label.text = Label.getLabel("whoiam");
			_controledBt.enabled = false;
			
			filters = [new DropShadowFilter(5,135,0,.3,10,10,1,3)];
			
			if(NativeApplication.supportsDockIcon){
			    var dockIcon:DockIcon = NativeApplication.nativeApplication.icon as DockIcon;
			    dockIcon.menu = createIconMenu();
			} else if (NativeApplication.supportsSystemTrayIcon){
			    systrayIconBuild(stage).menu = createIconMenu();
			}
			
			computePositions();
//			stage.addEventListener(Event.RESIZE, computePositions);
			addEventListener(MouseEvent.CLICK, clickHandler);
			_nameInput.addEventListener(FormComponentEvent.SUBMIT, submitHandler);
			_nameInput.addEventListener(Event.CHANGE, changeValueHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}

		/**
		 * Creates the systray/dock menu
		 */
		private function createIconMenu():NativeMenu {
			var stopCmd:NativeMenuItem = new NativeMenuItem("Exit");
		    var iconMenu:NativeMenu = new NativeMenu();
		    iconMenu.addItem(stopCmd);
		    stopCmd.addEventListener(Event.SELECT, exitAppHandler);
		    return iconMenu;
		}
		
		/**
		 * Exits the application
		 */
		private function exitAppHandler(event:Event):void {
			NativeApplication.nativeApplication.exit();
		}
		
		/**
		 * Called when window is pressed to drag it
		 */
		private function mouseDownHandler(event:MouseEvent):void {
			if(event.target is Validable) return;
			if(event.target is TextField && TextField(event.target).type == TextFieldType.INPUT) return;
			stage.nativeWindow.startMove();
		}
		
		/**
		 * Called when ENTER key is pressed in input to submit the form
		 */
		private function submitHandler(event:FormComponentEvent):void {
			_controledBt.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}
		
		/**
		 * Synchs the button's enable state with input's value to prevent from submitting empty value.
		 */
		private function changeValueHandler(event:Event = null):void {
			_controledBt.enabled = StringUtils.trim(_nameInput.value as String).length > 0;
		}
		
		/**
		 * Called when a component is clicked
		 */
		private function clickHandler(event:MouseEvent):void {
			if(event.target != _controledBt && event.target != _controlerBt) return;
			
			changeValueHandler();
			//If button is disabled but clicked, give focus to input
			if(!_controledBt.enabled && _controledBt.hitTestPoint(stage.mouseX, stage.mouseY, true)) {
				stage.focus = _nameInput;
				return;
			}
			
			if (event.target == _controledBt) {
				if(!_controledBt.enabled) return;
				FrontControler.getInstance().init(true, _nameInput.value as String);
			}else
			if(event.target == _controlerBt) {
				FrontControler.getInstance().init(false);
			}
			
			var target:TButton = event.target as TButton;
			if(target != null)  {
				_controledBt.enabled = _controlerBt.enabled = false;
				target.spinMode = true;
			}
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions(event:Event = null):void {
			var margin:int = 10;
			
			_controledBt.width = _controlerBt.width = _nameInput.width = Math.max(_controledBt.width, _controlerBt.width) + 20;
			
			PosUtils.hAlign(PosUtils.H_ALIGN_CENTER, margin, _label, _nameInput, _controledBt, _controlerBt);
			PosUtils.vPlaceNext(20, _label, _nameInput, _controledBt, _controlerBt);
			_nameInput.y += 5;
			_controledBt.y -= 5;
			
			_label.y += 3;
			_navBar.x = 0;//Avoid faked bounds for the drawRect
			
			graphics.clear();
			graphics.beginFill(0xffffff, 1);
			graphics.drawRect(0, 0, _nameInput.width + margin * 2, _controlerBt.y + _controlerBt.height + margin);
			graphics.endFill();

			var b:Rectangle = Screen.mainScreen.bounds;
			stage.nativeWindow.bounds = new Rectangle(	b.x + b.width*.5 - width*.5 - 25,
														b.y + b.height*.5 - height*.5 - 25,
														width + 50, height + 50);
			
			_navBar.x = width - _navBar.width;
			
			PosUtils.centerInStage(this);
		}
		
	}
}