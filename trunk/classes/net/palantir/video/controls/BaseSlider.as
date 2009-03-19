package net.palantir.video.controls {

	import flash.display.Shape;
	import flash.display.Sprite;

	public class BaseSlider extends Sprite {

		// PROPERTIES
		protected var _bg:Shape;
		protected var _col1:int;
		protected var _col2:int;
		protected var _col3:int;

		// CONSTRUCTOR
		public function BaseSlider(col1:int, col2:int, col3:int) {
			init(col1, col2, col3);
		};

		// METHODS
		// init
		private function init(col1:int, col2:int, col3:int):void {
			_col1 = (col1) ? col1 : 0x000000;
			_col2 = (col2) ? col2 : 0xFEFEFE;
			_col3 = (col3) ? col3 : col2;
		};
		// Build Base
		protected function buildBase(w:Number = 24):void {
			// Draw visuals
			_bg = new Shape();
			_bg.graphics.lineStyle();
			_bg.graphics.beginFill(0x000000, 0);
			_bg.graphics.drawRect(0, 0, w, 16);
			_bg.graphics.endFill();
			addChild(_bg);
		};
		// Center
		protected function center(spr:Sprite):void {
			spr.x = _bg.width / 2 - spr.width / 2;
			spr.y = _bg.height / 2 - spr.height / 2;
		};
		// Set Width
		public function setWidth(w:Number):void {
			// override in SeekSlider
		};
	};
};