package net.palantir.video.controls {

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class VolumeSlider extends BaseSlider {

		// PROPERTIES
		protected var _track:Sprite;
		protected var _triangle:Shape;
		protected var _slider:Sprite;
		protected var _sliderMask:Shape;
		protected var _trackMask:Shape;

		/**
		 * VolumeSlider constructor.
		 * 
		 * @param  col1  integer for foreground color 1
		 * @param  col2  integer for foreground color 2
		 * @param  col3  integer for foreground color 3
		 */
		public function VolumeSlider(col1:int, col2:int, col3:int) {
			super(col1, col2, col3);
			super.buildBase(28);
			init();
		};

		// METHODS
		/**
		 * Draws icon/ui graphics.
		 */
		private function init():void {
			// track
			_track = new Sprite();
			// triangle
			var _triangle = new Shape();
			drawTriangle(_triangle);
			_track.addChild(_triangle);
			// slider
			_slider = new Sprite();
			_slider.graphics.lineStyle();
			_slider.graphics.beginFill(_col1, 1);
			_slider.graphics.drawRect(0, 0, 24, 10);
			_slider.graphics.endFill();
			center(_slider);
			_track.addChild(_slider);
			// slider mask
			var _sliderMask = new Shape();
			drawTriangle(_sliderMask);
			_track.addChild(_sliderMask);
			_slider.mask = _sliderMask;
			addChild(_track);
			// track mask
			_trackMask = new Shape();
			_trackMask.graphics.lineStyle();
			_trackMask.graphics.beginFill(_col1, 1);
			_trackMask.graphics.drawRect(0, 3, 2.4, 10);
			_trackMask.graphics.drawRect(4.3, 3, 2.4, 10);
			_trackMask.graphics.drawRect(8.7, 3, 2.4, 10);
			_trackMask.graphics.drawRect(13.1, 3, 2.4, 10);
			_trackMask.graphics.drawRect(17.4, 3, 2.4, 10);
			_trackMask.graphics.drawRect(21.8, 3, 2.4, 10);
			_trackMask.graphics.endFill();
			addChild(_trackMask);
			_track.mask = _trackMask;
			/**
			 * Assigns event handlers.
			 */
			buttonMode = true;
			addEventListener(MouseEvent.MOUSE_DOWN, volumeStartDrag, false, 0, false);

		};
		/**
		 * Draws triangle shape (used for visual and mask).
		 */
		private function drawTriangle(sh:Shape):void {
			sh.graphics.lineStyle();
			sh.graphics.beginFill(_col1, 0.6); // 0x8D8D8D
			sh.graphics.moveTo(0, 8);
			sh.graphics.lineTo(24, 3);
			sh.graphics.lineTo(24, 13);
			sh.graphics.lineTo(0, 8);
			sh.graphics.endFill();
		};
		/**
		 * Starts slider knob dragging.
		 * 
		 * @param  evt  instance of MouseEvent class
		 */
		private function volumeStartDrag(evt:MouseEvent):void {
			addEventListener(MouseEvent.MOUSE_MOVE, updateSlider, false, 0, false);
			stage.addEventListener(MouseEvent.MOUSE_UP, volumeStopDrag, false, 0, false);
		};
		/**
		 * Stops slider knob dragging.
		 * 
		 * @param  evt  instance of MouseEvent class
		 */
		private function volumeStopDrag(evt:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, volumeStopDrag);
			removeEventListener(MouseEvent.MOUSE_MOVE, updateSlider);
		};
		/**
		 * Repositions slider knob to mouse location.
		 * 
		 * @param  evt  instance of MouseEvent class
		 */
		private function updateSlider(evt:MouseEvent):void {
			_slider.x = Math.min(
				Math.max(
					-_slider.width,
					evt.currentTarget.mouseX - _slider.width
				),
				0
			);
			dispatchEvent(new Event(Event.CHANGE));
		};
		// GETTER/SETTER
		/**
		 * Returns slider volume (position of knob on track).
		 */
		public function get volume():Number {
			return 100 - (_slider.x / _slider.width * -100);
		};
		/**
		 * Sets slider volume (position of knob on track).
		 * 
		 * @param  val  percent range 0 to 100
		 */
		public function set volume(val:Number):void {
			_slider.x = -(_slider.width - (val / 100 * _slider.width));
		};
		/**
		 * Returns slider width (accounts for false width caused
		 * by mask, depending on position of volume knob).
		 */
		public override function get width():Number {
			return _bg.width;
		};
	};
};