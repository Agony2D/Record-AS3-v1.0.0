package org.as3wavsound.sazameki.core {
	
	public class AudioSamples {
		public var _left:Vector.<Number>;
		public var _right:Vector.<Number>;
		private var _setting:AudioSetting;
		
		public function AudioSamples(setting:AudioSetting, length:Number = 0) {
			this._setting = setting;
			this._left = new Vector.<Number>(length, length > 0);
			if (setting.channels == 2) {
				this._right = new Vector.<Number>(length, length > 0);
			}
		}
		
		public function clearSamples():void {
			_left = new Vector.<Number>(length, true);
			if (setting.channels == 2) {
				_right = new Vector.<Number>(length, true);
			}
		}
		
		public function get length():int {return left.length;}
		public function get setting():AudioSetting {return _setting;}
		public function get left():Vector.<Number> {return _left;}
		public function get right():Vector.<Number> {return _right;}
	}
}