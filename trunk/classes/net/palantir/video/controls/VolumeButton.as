package net.palantir.video.controls {

	import flash.display.Shape;

	import net.palantir.video.controls.BaseButton;

	public class VolumeButton extends BaseButton {

		// PROPERTIES
		// none

		// CONSTRUCTOR
		public function VolumeButton(col:int = 0x000000) {
			super(col);
			init();
		};

		// METHODS
		// init
		private function init():void {
			// Draw visuals
			var horn:Shape = new Shape();
			horn.graphics.lineStyle();
			horn.graphics.beginFill(_col, 1);
			horn.graphics.drawRect(2, 5, 6, 6);
			horn.graphics.endFill();
			horn.graphics.beginFill(0xFFFFFF, 0);
			horn.graphics.drawRect(8, 5, 1, 6);
			horn.graphics.endFill();
			horn.graphics.beginFill(_col, 1);
			horn.graphics.moveTo(9, 5);
			horn.graphics.lineTo(13, 2);
			horn.graphics.lineTo(13, 14);
			horn.graphics.lineTo(9, 11);
			horn.graphics.endFill();
			addChild(horn);
		};
	};
};