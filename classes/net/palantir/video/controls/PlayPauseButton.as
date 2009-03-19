package net.palantir.video.controls {

	import net.palantir.video.controls.BaseButton;
	import net.palantir.video.controls.PauseButton;
	import net.palantir.video.controls.PlayButton;

	public class PlayPauseButton extends BaseButton {

		// PROPERTIES
		private var _toggled:Boolean;
		private var _playButton:PlayButton;
		private var _pauseButton:PauseButton;

		// CONSTRUCTOR
		public function PlayPauseButton(col:int = 0x000000) {
			super(col);
			init();
		};

		// METHODS
		// init
		private function init():void {
			// Draw visuals
			_playButton = new PlayButton(_col);
			addChild(_playButton);
			_pauseButton = new PauseButton(_col);
			_pauseButton.visible = false;
			addChild(_pauseButton);

			_toggled = false;
		};
		// Toggle
		public function toggle(b:Object = null):void {
			if (b == null) _toggled = !_toggled;
			else _toggled = Boolean(b);
			_playButton.visible = _toggled;
			_pauseButton.visible = !_toggled;
		};
	};
};