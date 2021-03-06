package com.whoiam.components {
	import com.nurun.components.button.IconAlign;
	import com.nurun.components.button.TextAlign;
	import com.nurun.components.form.ComboBox;
	import com.nurun.components.form.events.ListEvent;
	import com.nurun.trombi.graphics.ComboboxArrowIcon;
	import com.projectcocoon.p2p.vo.ClientVO;

	import flash.events.KeyboardEvent;
	import flash.utils.getTimer;
	
	/**
	 * 
	 * @author durss
	 * @date 7 mars 2012;
	 */
	public class TComboBox extends ComboBox {
		private var _lastTime:int;
		private var _history:Array;
		private var _defaultLabel:String;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>TComboBox</code>.
		 */
		public function TComboBox(label:String, openToTop:Boolean = false) {
			_defaultLabel = label;
			var bt:TButton = new TButton(label, "button", new ComboboxArrowIcon());
			super(bt, new TScrollbar(), null, null, openToTop);
			list.scrollPane.autoHideScrollers = false;
			list.scrollableList.allowMultipleSelection = false;
			list.scrollableList.group.allowNoSelection = true;
			bt.iconAlign = IconAlign.RIGHT;
			bt.textAlign = TextAlign.CENTER;
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * @inheritDoc
		 */
		override public function set selectedData(value:*):void {
			super.selectedData = value;
			
			if(value is ClientVO) {
				setLabel(ClientVO(value).clientName);
			}
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Adds a pre-skinned item.
		 */
		public function addSkinnedItem(label:String, data:*):TToggleButton {
			var bt:TToggleButton = new TToggleButton(label, "comboboxItem");
			super.addItem(bt, data);
			return bt;
		}
		
		/**
		 * Resets the list's selection to nothing
		 */
		public function reset():void {
			list.scrollableList.group.allowNoSelection = true;
			list.scrollableList.selectedIndex = -1;
			setLabel(_defaultLabel);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		override protected function keyUpHandler(event:KeyboardEvent):void  {
			_isKeyBoardChange = false;
			if(getTimer() - _lastTime > 800) {
				_history = [];
			}
		
			_history.push(String.fromCharCode(event.charCode));
			var i:int, len:int, items:Array, size:int, ref:String;
			ref = _history.join("").toLowerCase();
			size = _history.length;
			items = _list.scrollableList.items;
			len = items.length;
			for(i = 0; i < len; ++i) {
				if(TToggleButton(items[i]).label.substr(0, size).toLowerCase() == ref) {
					selectedIndex = i;
					setLabel( ClientVO(selectedData).clientName );
					break;
				}
			}
			
			_lastTime = getTimer();
		}
		
		override protected function selectItemHandler(event:ListEvent):void {
			if (ClientVO(event.data) != null) {
				setLabel( ClientVO(selectedData).clientName );
			}
			super.selectItemHandler(event);
			list.scrollableList.group.allowNoSelection = false;
		}

		private function setLabel(label:String):void {
			if(label != null && label.length > 20) label = label.substr(0, 20)+"…";
			TButton(_button).label = label;
		}
		
	}
}