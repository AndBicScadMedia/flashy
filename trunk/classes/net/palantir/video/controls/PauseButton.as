package net.palantir.video.controls {

	import flash.display.Shape;

	import net.palantir.video.controls.BaseButton;

	public class PauseButton extends BaseButton {

		// PROPERTIES
		// none

		// CONSTRUCTOR
		public function PauseButton(col:int = 0x000000) {
			super(col);
			init();
		};

		// METHODS
		// init
		private function init():void {
			// Draw visuals
			var bars:Shape = new Shape();
			bars.graphics.lineStyle();
			bars.graphics.beginFill(_col, 1);
			bars.graphics.drawRect(0, 0, 2, 8);
			bars.graphics.endFill();
			bars.graphics.beginFill(0xFFFFFF, 0);
			bars.graphics.drawRect(3, 0, 2, 8);
			bars.graphics.endFill();
			bars.graphics.beginFill(_col, 1);
			bars.graphics.drawRect(5, 0, 2, 8);
			bars.graphics.endFill();
			center(bars);
			addChild(bars);
		};
	};
};