package net.palantir.video.controls {

	import net.palantir.video.controls.BaseButton;
	import net.palantir.video.controls.VolumeButton;
	import net.palantir.video.controls.MuteButton;

	public class VolumeToggleButton extends BaseButton {

		// PROPERTIES
		private var _toggled:Boolean;
		private var _volumeButton:VolumeButton;
		private var _muteButton:MuteButton;

		// CONSTRUCTOR
		public function VolumeToggleButton(col:int = 0x000000) {
			super(col);
			init();
		};

		// METHODS
		// init
		private function init():void {
			// Draw visuals
			_volumeButton = new VolumeButton(_col);
			addChild(_volumeButton);
			_muteButton = new MuteButton(_col);
			_muteButton.visible = false;
			addChild(_muteButton);

			_toggled = false;
		};
		// Toggle
		public function toggle(b:Object = null):void {
			if (b == null) _toggled = !_toggled;
			else _toggled = Boolean(b);
			_volumeButton.visible = !_toggled;
			_muteButton.visible = _toggled;
		};
	};
};