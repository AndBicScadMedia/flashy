package net.palantir.video.controls {

	import flash.display.Shape;
	import flash.display.Sprite;

	public class BaseButton extends Sprite {

		// PROPERTIES
		protected var _bg:Shape;
		protected var _col:int;

		// CONSTRUCTOR
		public function BaseButton(col:int = 0x000000) {
			init(col);
		};

		// METHODS
		// init
		private function init(col:int):void {
			_col = col;
			buildBase();
		};
		// Build Base
		private function buildBase():void {
			// Prep
			this.buttonMode = true;
			// Draw visuals
			_bg = new Shape();
			_bg.graphics.lineStyle();
			_bg.graphics.beginFill(0xFFFFFF, 0);
			_bg.graphics.drawRect(0, 0, 16, 16);
			_bg.graphics.endFill();
			addChild(_bg);
		};
		// Center
		protected function center(sh:Shape):void {
			sh.x = _bg.width / 2 - sh.width / 2;
			sh.y = _bg.height / 2 - sh.height / 2;
		};
	};
};