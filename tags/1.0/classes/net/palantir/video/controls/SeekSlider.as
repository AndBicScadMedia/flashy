package net.palantir.video.controls {

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;


	public class SeekSlider extends BaseSlider {

		// PROPERTIES
		protected var _track:Sprite;
		protected var _totalBar:Sprite;
		protected var _progressBar:Sprite;
		protected var _knob:Sprite;
		protected var _dragConstraint:Rectangle;

		// CONSTRUCTOR
		public function SeekSlider(col1:int, col2:int, col3:int) {
			super(col1, col2, col3);
			super.buildBase(52);
			init();
		};

		// METHODS
		// init
		private function init():void {
			// Draw visuals
			// track
			_track = new Sprite();
			// duration bar
			_totalBar = new Sprite();
			_totalBar.graphics.lineStyle();
			_totalBar.graphics.beginFill(_col1, 0.3); // 0x8D8D8D
			_totalBar.graphics.drawRect(0, 0, 40, 4);
			_totalBar.graphics.endFill();
			_track.addChild(_totalBar);
			// progress bar
			_progressBar = new Sprite();
			_progressBar.graphics.lineStyle();
			_progressBar.graphics.beginFill(_col1, 0.3); // 0x5B5B5B
			_progressBar.graphics.drawRect(0, 0, 40, 4);
			_progressBar.graphics.endFill();
			_track.addChild(_progressBar);
			center(_track);
			addChild(_track);
			// knob
			setDragConstraint();
			var colors:Array = new Array(_col2, _col3); // 0xFEFEFE, 0xCFCFCF
			var alphas:Array = new Array(100, 100);
			var ratios:Array = new Array(0, 255);
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(9.4, 10.3, 1.570796326795, -5.36, -7.72);
			_knob = new Sprite();
			_knob.graphics.lineStyle(1, _col1, 0.4); // 0x8C8C8C
			_knob.graphics.beginGradientFill("radial", colors, alphas, ratios, matrix);
			_knob.graphics.drawCircle(0, 0, 6);
			_knob.graphics.endFill();
			_knob.x = 8;
			_knob.y = 8;
			_knob.buttonMode = true;
			addChild(_knob);

			// Assign event handlers
			_knob.addEventListener(MouseEvent.MOUSE_DOWN, seekStartDrag, false, 0, false);

		};
		// Set Width
		public override function setWidth(w:Number):void {
			_bg.width = w;
			_track.x = _bg.x + _knob.width / 2;
			_track.width = w - _knob.width;
			_knob.x = Math.min(_knob.x, w - (_knob.width / 2));
			setDragConstraint();
		};
		// Set Drag Constraint
		private function setDragConstraint():void {
			_dragConstraint = new Rectangle(_track.x, _track.y + _track.height / 2, _track.width, 0);
		};
		// Seek Start Drag
		private function seekStartDrag(evt:MouseEvent):void {
			_knob.startDrag(true, _dragConstraint);
			stage.addEventListener(MouseEvent.MOUSE_UP, seekStopDrag, false, 0, false);
			dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
		};
		// Seek Stop Drag
		private function seekStopDrag(evt:MouseEvent):void {
			_knob.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_UP, seekStopDrag);
			dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
		};
		// GETTER/SETTER
		// seekValue
		public function get seekValue():Number {
			return _knob.x / _track.width;
		};
		public function set seekValue(val:Number):void {
			if (isNaN(val)) {
				_knob.x = _track.x;
			} else {
				_knob.x = _track.x + (_track.width * val);
			}
		};
		// progress
		public function get progressValue():Number {
			return _progressBar.width / _totalBar.width;
		};
		public function set progressValue(val:Number):void {
			_progressBar.width = val * _totalBar.width;
		};
	};
};