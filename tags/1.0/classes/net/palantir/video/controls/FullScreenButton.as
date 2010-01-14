package net.palantir.video.controls {

	import flash.display.Shape;

	import net.palantir.video.controls.BaseButton;

	public class FullScreenButton extends BaseButton {

		// PROPERTIES
		// none

		// CONSTRUCTOR
		public function FullScreenButton(col:int = 0x000000) {
			super(col);
			init();
		};

		// METHODS
		// init
		private function init():void {
			// Draw visuals
			var rect:Shape = new Shape();
			rect.graphics.lineStyle();
			rect.graphics.beginFill(_col, 1);
			rect.graphics.drawRect(0, 0, 7, 6);
			rect.graphics.endFill();
			center(rect);
			addChild(rect);
			var arrows:Shape = new Shape();
			arrows.graphics.lineStyle();
			arrows.graphics.lineStyle(1, _col, 1);
			// verticals
			arrows.graphics.moveTo(2, 2);
			arrows.graphics.lineTo(2, 4);
			arrows.graphics.moveTo(2, 12);
			arrows.graphics.lineTo(2, 14);
			arrows.graphics.moveTo(14, 2);
			arrows.graphics.lineTo(14, 4);
			arrows.graphics.moveTo(14, 12);
			arrows.graphics.lineTo(14, 14);
			// horizonals
			arrows.graphics.moveTo(2, 2);
			arrows.graphics.lineTo(4, 2);
			arrows.graphics.moveTo(12, 2);
			arrows.graphics.lineTo(14, 2);
			arrows.graphics.moveTo(2, 14);
			arrows.graphics.lineTo(4, 14);
			arrows.graphics.moveTo(12, 14);
			arrows.graphics.lineTo(14, 14);
			addChild(arrows);
		};
	};
};