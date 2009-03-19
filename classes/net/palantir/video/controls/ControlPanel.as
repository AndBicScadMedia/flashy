package net.palantir.video.controls {

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import fl.transitions.Tween;
	import fl.transitions.easing.None;


	import net.palantir.video.controls.BaseButton;
	import net.palantir.video.controls.BaseSlider;

		public class ControlPanel extends Sprite {

		// PROPERTIES
		private var _col1:int;
		private var _col2:int;
		private var _ready:Boolean;
		private var _controls:Array;
		private var _varWidthIndex:int;
		private var _preVarWidth:Number;
		private var _postVarWidth:Number;
		private var _tw:Tween;
		private var _duration:Number;

		// CONSTRUCTOR
		public function ControlPanel(col1:int, col2:int) {
			trace();
			_col1 = (col1) ? col1 : 0xFEFEFE;
			_col2 = (col2) ? col2 : col1;
			this.addEventListener(Event.ADDED_TO_STAGE, onInit, false, 0, false);
		};

		// METHODS
		// Add Button
		public function addButton(btn:BaseButton):void {
			_controls.push(btn);
			if (_varWidthIndex >= 0) {
				_postVarWidth += btn.width;
				
			} else {
				_preVarWidth += btn.width;
			}
		};
		public function addSlider(sdr:BaseSlider, isVariableWidth:Boolean = false):void {
			_controls.push(sdr);
			if (isVariableWidth) _varWidthIndex = _controls.length - 1;
			else _postVarWidth += sdr.width;
			trace(sdr.width);
		};
		// Resize
		public function resize():void {
			if (_ready) {
				var sw:int = Math.round(stage.stageWidth);
				var sh:int = Math.round(stage.stageHeight);
				// Control panel
				this.y = sh - this.height;
				this.width = sw;
				// Controls
				var len:int = _controls.length;
				for (var i:int = 0; i < len; i++) {
					var thisCtrl:Object = _controls[i];
					var prevCtrl:Object = _controls[i - 1];
					thisCtrl.y = this.y;
					if (i > 0) {
						// Most buttons ...
						thisCtrl.x = prevCtrl.x + prevCtrl.width;
						// The variable width slider ...
						if (thisCtrl is BaseSlider) {
							if (i == _varWidthIndex) {
								thisCtrl.setWidth(sw - (_preVarWidth + _postVarWidth));
							}
						}
					}
				}
			}
		};
		// Show
		public function show():void {
			_tw = new Tween(this, "alpha", None.easeNone, this.alpha, 1, _duration, true);
			fadeControls(true);
		};
		// Hide
		public function hide():void {
			_tw = new Tween(this, "alpha", None.easeNone, this.alpha, 0, _duration, true);
			fadeControls(false);
		};
		// Fade
		private function fadeControls(b:Boolean):void {
			var len:int = _controls.length;
			for (var i:int = 0; i < len; i++) {
				if (b) {
					_tw = new Tween(_controls[i], "alpha", None.easeNone, this.alpha, 1, _duration, true);
				} else {
					_tw = new Tween(_controls[i], "alpha", None.easeNone, this.alpha, 0, _duration, true);
				}
				_controls[i].mouseEnabled = b;
			}
		}

		// EVENT HANDLERS
		// onInit
		private function onInit(evt:Event):void {
			// Prep
			_controls = new Array();
			_varWidthIndex = -1;
			_preVarWidth = 0;
			_postVarWidth = 0;
			_duration = 0.15;

			// Draw visuals
			var bg:Shape = new Shape();

			var colors:Array = new Array(_col1, _col2);
			var alphas:Array = new Array(100, 100);
			var ratios:Array = new Array(0, 255);
			var matrix:Matrix = new Matrix();
			// gradient box: width, height, rotation (radians), x, y
			//matrix.createGradientBox(300, 16, 4.712388980384587, 0, 0);
			matrix.createGradientBox(300, 16, 1.570796326795, 0, 0);

			bg.graphics.lineStyle();
			bg.graphics.beginGradientFill("linear", colors, alphas, ratios, matrix);
			bg.graphics.drawRect(0, 0, 300, 16);
			bg.graphics.endFill();
			addChild(bg);

			// Housekeeping
			_ready = true;
			this.removeEventListener(Event.ADDED_TO_STAGE, onInit);
		};

		// GETTER/SETTER

		// UTILITIES
		
	};
};