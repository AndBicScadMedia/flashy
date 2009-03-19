package net.palantir.video.controls {

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;

	import fl.transitions.Tween;
	import fl.transitions.easing.None;

	//import net.palantir.video.controls.ButtonBase;

	public class OverlayPlayButton extends Sprite {

		// PROPERTIES
		private var _ready:Boolean;
		private var _tw:Tween;
		private var _duration:Number;

		// CONSTRUCTOR
		public function OverlayPlayButton() {
			this.addEventListener(Event.ADDED_TO_STAGE, onInit, false, 0, false);
		};

		// METHODS
		// Show
		public function show():void {
			_tw = new Tween(this, "alpha", None.easeNone, this.alpha, 1, _duration, true);
		};
		// Hide
		public function hide():void {
			_tw = new Tween(this, "alpha", None.easeNone, this.alpha, 0, _duration, true);
		};
		// Resize
		public function resize():void {
			if (_ready) {
				var sw:int = Math.round(stage.stageWidth);
				var sh:int = Math.round(stage.stageHeight);
				this.x = sw / 2 - this.width / 2;
				this.y = sh / 2 - this.height / 2;
			}
		};

		// EVENT HANDLERS
		// onInit
		private function onInit(evt:Event):void {
			
			// Prep
			_duration = 0.25;
			buttonMode = true;

			// Draw visuals
			var bg:Shape = new Shape();
			bg.graphics.lineStyle(1, 0x000000, 0.7, false);
			bg.graphics.beginFill(0x000000, 0.7);
			bg.graphics.drawRoundRect(0, 0, 80, 80, 8, 8);
			bg.graphics.endFill();
			addChild(bg);
			var arrow:Shape = new Shape();
			arrow.graphics.lineStyle(1, 0xFFFFFF, 1, false);
			arrow.graphics.beginFill(0xFFFFFF, 1);
			arrow.graphics.lineTo(32, 22);
			arrow.graphics.lineTo(0, 44);
			arrow.graphics.endFill();
			addChild(arrow);
			arrow.x = bg.width / 2 - arrow.width / 2;
			arrow.y = bg.height / 2 - arrow.height / 2;

			// Housekeeping
			_ready = true;
			this.removeEventListener(Event.ADDED_TO_STAGE, onInit);
		};
		
	};
};