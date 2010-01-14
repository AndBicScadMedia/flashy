package net.palantir.video.controls {

	import flash.display.Shape;

	import net.palantir.video.controls.BaseButton;

	public class PrevButton extends BaseButton {

		// PROPERTIES
		// none

		// CONSTRUCTOR
		public function PrevButton(col:int = 0x000000) {
			super(col);
			init();
		};

		// METHODS
		// init
		private function init():void {
			// Draw visuals
			var arrow:Shape = new Shape();
			arrow.graphics.lineStyle();
			arrow.graphics.beginFill(_col, 1);
			arrow.graphics.moveTo(6, 0);
			arrow.graphics.lineTo(0, 4);
			arrow.graphics.lineTo(6, 8);
			arrow.graphics.endFill();
			center(arrow);
			addChild(arrow);
			var line:Shape = new Shape();
			line.graphics.lineStyle(1, _col, 1);
			line.graphics.moveTo(4, 4);
			line.graphics.lineTo(4, 12);
			addChild(line);
		};
	};
};