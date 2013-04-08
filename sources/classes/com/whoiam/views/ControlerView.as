package com.whoiam.views {
	import com.whoiam.components.TToggleButton;
	import com.nurun.components.form.events.FormComponentEvent;
	import com.nurun.components.form.events.ListEvent;
	import com.nurun.components.invalidator.Validable;
	import com.nurun.components.text.CssTextField;
	import com.nurun.graphics.common.LoaderSpinningSmallGraphic;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.utils.pos.PosUtils;
	import com.projectcocoon.p2p.vo.ClientVO;
	import com.whoiam.components.NavBar;
	import com.whoiam.components.TButton;
	import com.whoiam.components.TComboBox;
	import com.whoiam.components.TInput;
	import com.whoiam.components.Tooltip;
	import com.whoiam.controler.FrontControler;
	import com.whoiam.events.ConnectionManagerEvent;
	import com.whoiam.model.Model;
	import com.whoiam.p2p.ConnectionManager;
	import com.whoiam.vo.ActionType;

	import flash.display.DisplayObject;
	import flash.display.Screen;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.utils.Dictionary;


	/**
	 * DIsplays the controls panel.
	 * 
	 * @author durss
	 * @date 6 févr. 2013;
	 */
	public class ControlerView extends AbstractView {
		private var _blinkBt:TButton;
		private var _screamBt:TButton;
		private var _usersList:TComboBox;
		private var _holder:Sprite;
		private var _waitLabel:CssTextField;
		private var _spin:LoaderSpinningSmallGraphic;
		private var _ready:Boolean;
//		private var _blueBt:TButton;
		private var _glitchBt:TButton;
		private var _deadPixelsBt:TButton;
		private var _buttonToAction:Dictionary;
		private var _input : TInput;
		private var _fileBt:TButton;
		private var _tooltip:Tooltip;
		private var _buttonToTooltip:Dictionary;
		private var _navBar:NavBar;
		private var _title:CssTextField;
		private var _mobileMode : Boolean;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ControlerView</code>.
		 */
		public function ControlerView() {
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
			visible = model.connected && !model.controledMode;
			if(visible && !_ready) {
				_ready = true;
				_mobileMode = model.mobileMode;
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
			_holder		= addChild(new Sprite()) as Sprite;
			_waitLabel	= addChild(new CssTextField("waitPeers")) as CssTextField;
			_spin		= addChild(new LoaderSpinningSmallGraphic()) as LoaderSpinningSmallGraphic;
			_tooltip	= new Tooltip();
			if(!_mobileMode) {
				_navBar	= addChild(new NavBar()) as NavBar;
			}
			
			_title			= _holder.addChild(new CssTextField("controlerTitle")) as CssTextField;
			_usersList		= _holder.addChild(new TComboBox(Label.getLabel("selectUser"))) as TComboBox;
			_blinkBt		= _holder.addChild(new TButton(Label.getLabel("action-blink"))) as TButton;
			_screamBt		= _holder.addChild(new TButton(Label.getLabel("action-scream"))) as TButton;
//			_blueBt			= _holder.addChild(new TButton(Label.getLabel("action-blue"))) as TButton;
			_glitchBt		= _holder.addChild(new TButton(Label.getLabel("action-glitch"))) as TButton;
			_deadPixelsBt	= _holder.addChild(new TButton(Label.getLabel("action-deadPixels"))) as TButton;
			_fileBt			= _holder.addChild(new TButton(Label.getLabel("action-file"))) as TButton;
			_input			= _holder.addChild(new TInput(Label.getLabel("action-defaultTrollText"))) as TInput;

			_buttonToAction = new Dictionary();
			_buttonToAction[_blinkBt] = ActionType.BLINK;
			_buttonToAction[_screamBt] = ActionType.SCREAM;
//			_buttonToAction[_blueBt] = ActionType.BLUE;
			_buttonToAction[_glitchBt] = ActionType.GLITCH;
			_buttonToAction[_deadPixelsBt] = ActionType.DEAD_PIXEL;
			_buttonToAction[_fileBt] = ActionType.FILE;
			
			_buttonToTooltip = new Dictionary();
			_buttonToTooltip[_input] = Label.getLabel("tt-input");
			_buttonToTooltip[_fileBt] = Label.getLabel("tt-file");
			
			_holder.visible = false;
			_waitLabel.text = Label.getLabel("waitForPeers");
			if(!_mobileMode) _title.text = Label.getLabel("controlerTitle");
			
			if(!_mobileMode) {
				filters = [new DropShadowFilter(5,135,0,.3,10,10,1,3)];
			}
			
			disableOptions();
			
			addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(MouseEvent.MOUSE_OUT, rollOutHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			_input.addEventListener(MouseEvent.MOUSE_OVER, rollOverHandler);
			_fileBt.addEventListener(MouseEvent.MOUSE_OVER, rollOverHandler);
			_input.addEventListener(FormComponentEvent.SUBMIT, submitTextHandler);
			_usersList.addEventListener(ListEvent.SELECT_ITEM, selectUserHandler);
			ConnectionManager.getInstance().addEventListener(ConnectionManagerEvent.ON_USER_UPDATE, peerChangeHandler);
			ConnectionManager.getInstance().addEventListener(ConnectionManagerEvent.ON_USER_DISCONNECT, peerChangeHandler);
			
			computePositions();
		}
		
		/**
		 * Disables all the options
		 */
		private function disableOptions():void {
			//Disables all the buttons
			var i:int, len:int, item:TButton;
			len = _holder.numChildren;
			for(i = 0; i < len; ++i) {
				item = _holder.getChildAt(i) as TButton;
				if(item == null) continue;
				item.enabled = false;
			}
			_input.alpha = .3;
			_input.tabEnabled = _input.tabChildren = false;
			_input.mouseEnabled = _input.mouseChildren = false;
		}

		/**
		 * Called when a component is rolled out
		 */
		private function rollOutHandler(event:MouseEvent):void {
			hideToolTip();
		}
		
		/**
		 * Called when a component is rolled over
		 */
		private function rollOverHandler(event:MouseEvent):void {
			var label:String = _buttonToTooltip[event.currentTarget];
			if(label != null) {
				addChild(_tooltip);
				_tooltip.populate(label);
				_tooltip.startMouseFollow();
			}
		}
		
		/**
		 * Called when a text is submitted
		 */
		private function submitTextHandler(event:FormComponentEvent):void {
			FrontControler.getInstance().sendActionTo(ActionType.WRITE, _usersList.selectedData as ClientVO, _input.text);
			_input.text = "";
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
		 * Called when a user is selected.
		 */
		private function selectUserHandler(event:Event):void {
			//Enables all the buttons
			var i:int, len:int, item:TButton;
			len = _holder.numChildren;
			for(i = 0; i < len; ++i) {
				item = _holder.getChildAt(i) as TButton;
				if(item == null) continue;
				item.enabled = true;
			}
			_input.alpha = 1;
			_input.tabEnabled = _input.tabChildren = true;
			_input.mouseEnabled = _input.mouseChildren = true;
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions(event:Event = null):void {
			var margin:int = _mobileMode? 0 : 10;
			
			_waitLabel.width = 300;
			var i:int, len:int, py:int, item:DisplayObject;
			len = _holder.numChildren;
//			py = _navBar.height;
			for(i = 0; i < len; ++i) {
				item = _holder.getChildAt(i);
				item.width = _waitLabel.width;
				if(_mobileMode) item.height = 60;
				item.y = py;
				py += item.height + 10;
				if(_mobileMode) py += 5;
			}
			_holder.addChild(_usersList);//Bring it to front to open the list over the rest.
			
			_spin.x = _usersList.width * .5 + margin;
			_spin.y = _spin.height;//prevent from negative bounds on the drawRect
			_waitLabel.y = 0;
			
			if(!_mobileMode) {
				_navBar.x = 0;
				
				graphics.clear();
				graphics.beginFill(0xffffff, 1);
				graphics.drawRect(0, 0, width + margin * 2, height + margin * 2);
				graphics.endFill();
			}
			
			_spin.y = Math.round(height / scaleY * .6) + margin;
			_waitLabel.y = Math.round(_spin.y - _spin.height * .5 - _waitLabel.height);
			_holder.x += margin;
			_holder.y += margin;
			
			if(!_mobileMode) _navBar.x = width - _navBar.width;
			
			if(!_mobileMode) {
				var b:Rectangle = Screen.mainScreen.bounds;
				stage.nativeWindow.bounds = new Rectangle(	b.x + b.width*.5 - width*.5 - 25,
															b.y + b.height*.5 - height*.5 - 25,
															width + 50, height + 50 );
				PosUtils.centerInStage(this);
			}else{
				PosUtils.hCenterIn(this, stage);
			}
		}
		
		/**
		 * Called when a component is clicked
		 */
		private function clickHandler(event:MouseEvent):void {
			hideToolTip();
			if(_buttonToAction[ event.target ] == undefined) return;
			
			var peer:ClientVO = _usersList.selectedData as ClientVO;
			
			if(_buttonToAction[ event.target ] == ActionType.FILE) {
				FrontControler.getInstance().sendFile(peer);
				return;
			}
			
			FrontControler.getInstance().sendActionTo(_buttonToAction[ event.target ], peer);
		}
		
		/**
		 * Called when a peer joins or leaves the group.
		 */
		private function peerChangeHandler(event:ConnectionManagerEvent):void {
			var prevSelected:ClientVO = _usersList.selectedData;
			_holder.visible = ConnectionManager.getInstance().clients.length > 0;
			var p:Vector.<ClientVO> = ConnectionManager.getInstance().clients;
			var i:int, len:int;
			len = p.length;
			_usersList.removeAll();
			_usersList.reset();
			for (i = 0; i < len; ++i) {
				var bt:TToggleButton = _usersList.addSkinnedItem(p[i].clientName, p[i]);
				if(_mobileMode) bt.height = 60;
				if(prevSelected != null && p[i].clientName == prevSelected.clientName) {
					_usersList.selectedIndex = i;
				}
			}
			if(_usersList.selectedIndex == -1) {
				disableOptions();
			}
			_waitLabel.visible = _spin.visible = !_holder.visible;
		}
		
		/**
		 * Hides the tooltip
		 */
		private function hideToolTip():void {
			_tooltip.stopMouseFollow();
			if(contains(_tooltip)) removeChild(_tooltip);
		}
		
	}
}