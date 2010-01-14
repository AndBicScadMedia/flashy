package net.palantir.video.controls {

	import flash.display.Shape;

	import net.palantir.video.controls.BaseButton;

	public class PlayButton extends BaseButton {

		// PROPERTIES
		// none

		// CONSTRUCTOR
		public function PlayButton(col:int = 0x000000) {
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
			arrow.graphics.lineTo(6, 4);
			arrow.graphics.lineTo(0, 8);
			arrow.graphics.endFill();
			center(arrow);
			addChild(arrow);
		};
	};
};