/**
 * @file
 *
 * Custom module for site-specific configuration.
 *
 * @copyright (C) Copyright 2009 Palantir.net
 * @license http://www.gnu.org/licenses/gpl-2.0.html
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

﻿package net.palantir.video {

	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.media.Video;
	import flash.media.SoundTransform;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.utils.Timer;

	import net.palantir.video.controls.ControlPanel;
	import net.palantir.video.controls.BaseButton;
	import net.palantir.video.controls.BaseSlider;
	import net.palantir.video.controls.PlayPauseButton;
	import net.palantir.video.controls.PrevButton;
	import net.palantir.video.controls.NextButton;
	import net.palantir.video.controls.SeekSlider;
	import net.palantir.video.controls.FullScreenButton;
	import net.palantir.video.controls.VolumeToggleButton;
	import net.palantir.video.controls.VolumeSlider;
	import net.palantir.video.controls.OverlayPlayButton;

	public class VideoPlayer extends Sprite {

		// PROPERTIES
		// general
		private var _video:Video;
		private var _videoContainer:Sprite;
		private var _connection:NetConnection;
		private var _stream:NetStream;
		private var _poster:Loader;
		private var _volume:SoundTransform;
		private var _volumeBackup:Number;
		private var _duration:Number;
		private var _playlist:XML;
		private var _ns:Namespace;
		private var _currentFile:int;
		private var _isPlaying:Boolean;
		private var _replay:Boolean;
		private var _uiControls:Array;
		private var _uiColors:Array;
		private var _uiBgColor:Array;
		private var _uiHideTimer:Timer;
		private var _uiDisabled:Boolean;
		// ui
		private var _controlPanel:ControlPanel;
		private var _playPauseButton:PlayPauseButton;
		private var _prevButton:PrevButton;
		private var _nextButton:NextButton;
		private var _seekSlider:SeekSlider;
		private var _fullScreenButton:FullScreenButton;
		private var _volumeToggleButton:VolumeToggleButton;
		private var _volumeSlider:VolumeSlider;
		private var _overlayPlayButton:OverlayPlayButton;
		private var _output:TextField; // DEBUGGING

		// CONSTRUCTOR
		public function VideoPlayer() {
			this.addEventListener(Event.ADDED_TO_STAGE, onInit, false, 0, false);
		};

		// METHODS
		// Connect
		private function connect(file:String):void {
			_connection.close();
			if (isHTTPRequest(file)) {
				_connection.connect(null);
			} else {
				// If RTMP and not already used ...
				if (_connection.uri != null && 	_connection.uri != getFilePath(file)) {
					_connection.connect(getFilePath(file));
				}
			}
		};
		// Load
		private function load(video:XML):void {
			default xml namespace = _ns;
			connect(video..location.toString());
			if (getBoolean(root.loaderInfo.parameters.autoPlay)) {
				play(video);
				if (_overlayPlayButton) _overlayPlayButton.hide();
			} else {
				cue(video);
				if (_overlayPlayButton) _overlayPlayButton.show();
			}
			if (_controlPanel) {
				if (getBoolean(video..options.@disableControls.toString())) {
					_uiDisabled = true;
					stage.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOverStage);
					_controlPanel.hide();
				} else {
					if (_uiDisabled) {
						_uiDisabled = false;
						_controlPanel.show();
						if (getBoolean(root.loaderInfo.parameters.uiAutoHide)) {
							stage.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverStage, false, 0, false);
							_uiHideTimer.start();
						}
					}
				}
			}
			addEventListener(Event.ENTER_FRAME, onLoadStream, false, 0, false);
		};
		// Cue
		private function cue(video:XML):void {
			var poster:String = video.image.toString();
			if (poster && poster != "") {
				_videoContainer.visible = false;
				var req:URLRequest = new URLRequest(poster);
				_poster.load(req);
			} else {
				_poster.unload();
			}
			play(video);
			_isPlaying = false;
			_stream.pause();
			_stream.seek(0);
			if (_playPauseButton) _playPauseButton.toggle(true);
			if (_seekSlider) {
				seekStop();
				_seekSlider.seekValue = 0;
			}
		};
		// Play
		private function play(video:XML):void {
			_isPlaying = true;
			_replay = false;
			_stream.play(video..location.toString());
			if (_seekSlider) seekStart();
		};
		// Load Prev
		private function loadPrev(evt:MouseEvent = null):void {
			trace(_currentFile);
			if (--_currentFile < 0) _currentFile = (_playlist.trackList.children().length() - 1);
			load(_playlist..track[_currentFile]);
		};
		// Load Next
		private function loadNext(evt:MouseEvent = null):void {
			trace(_currentFile);
			if (++_currentFile > (_playlist.trackList.children().length() - 1)) _currentFile = 0;
			load(_playlist..track[_currentFile]);
		};
		// Set Volume
		private function setVolume(vol:Number):void {
			// Constrain to 0 through 100
			vol = (isNaN(vol) || vol > 100) ? 1 : (vol < 4.5) ? 0 : vol / 100;
			_volume = _stream.soundTransform;
			_volume.volume = vol;
			_stream.soundTransform = _volume;
			if (_volumeToggleButton) _volumeToggleButton.toggle(!Boolean(vol));
			_volumeBackup = vol;
		};
		// Build Controls
		private function buildControls():void {
			var param:String = root.loaderInfo.parameters.uiControls;
			param = (param) ? param : "PlayPause|Prev|Next|Seek|FullScreen|MuteUnmute|Volume";
			if (param.toLowerCase() != "none") {
				_uiControls = param.split("|");
				// UI colors
				param = root.loaderInfo.parameters.uiColors;
				param = (param) ? param : "#000000|#000000|#000000|#000000|#000000|#000000|#000000";
				_uiColors = getColorsFromParam(param);
				// Control panel
				param = root.loaderInfo.parameters.uiBgColor;
				param = (param) ? param : "#FEFEFE|#CCCCCC";
				_uiBgColor = getColorsFromParam(param);
				_controlPanel = new ControlPanel(_uiBgColor[0], (_uiBgColor.length > 1) ? _uiBgColor[1] : null);
				addChild(_controlPanel);
				// UI controls
				var len:int = _uiControls.length;
				for (var i:int = 0; i < len; i++) {
					switch(_uiControls[i].toLowerCase()) {
						case "playpause":
							// PlayPause button
							_playPauseButton = new PlayPauseButton(_uiColors[i]);
							addChild(_playPauseButton);
							_controlPanel.addButton(BaseButton(_playPauseButton));
							_playPauseButton.addEventListener(MouseEvent.CLICK, onTogglePlay, false, 0, false);
							break;
						case "prev":
							// Prev button
							if (_playlist.trackList.children().length() > 1) {
								_prevButton = new PrevButton(_uiColors[i]);
								addChild(_prevButton);
								_controlPanel.addButton(BaseButton(_prevButton));
								_prevButton.addEventListener(MouseEvent.CLICK, loadPrev, false, 0, false);
							}
							break;
						case "next":
							// Next button
							if (_playlist.trackList.children().length() > 1) {
								_nextButton = new NextButton(_uiColors[i]);
								addChild(_nextButton);
								_controlPanel.addButton(BaseButton(_nextButton));
								_nextButton.addEventListener(MouseEvent.CLICK, loadNext, false, 0, false);
							}
							break;
						case "seek":
							// Seek slider
							_seekSlider = new SeekSlider(_uiColors[i], _uiBgColor[0], (_uiBgColor.length > 1) ? _uiBgColor[1] : null);
							addChild(_seekSlider);
							_controlPanel.addSlider(BaseSlider(_seekSlider), true);
							_seekSlider.addEventListener(MouseEvent.MOUSE_UP, onSeekMouseUp, false, 0, false);
							_seekSlider.addEventListener(MouseEvent.MOUSE_DOWN, onSeekMouseDown, false, 0, false);
							break;
						case "fullscreen":
							if (minVersionIs("9,0,115,0")) {
								// FullScreen button
								_fullScreenButton = new FullScreenButton(_uiColors[i]);
								addChild(_fullScreenButton);
								_controlPanel.addButton(BaseButton(_fullScreenButton));
								_fullScreenButton.addEventListener(MouseEvent.CLICK, onToggleFullScreen, false, 0, false);
							}
							break;
						case "muteunmute":
							// VolumeToggle button
							_volumeToggleButton = new VolumeToggleButton(_uiColors[i]);
							addChild(_volumeToggleButton);
							_controlPanel.addButton(BaseButton(_volumeToggleButton));
							_volumeToggleButton.addEventListener(MouseEvent.CLICK, onToggleVolume, false, 0, false);
							break;
						case "volume":
							// Volume slider
							_volumeSlider = new VolumeSlider(_uiColors[i], 0, 0);
							addChild(_volumeSlider);
							_controlPanel.addSlider(BaseSlider(_volumeSlider), false);
							_volumeSlider.volume = _stream.soundTransform.volume * 100;
							_volumeSlider.addEventListener(Event.CHANGE, onVolumeChange, false, 0, false);
							break;
					}
				}
				if (getBoolean(root.loaderInfo.parameters.uiAutoHide)) {
					_uiHideTimer.start();
				}
			}
			// Overlay Play Button
			_overlayPlayButton = new OverlayPlayButton();
			_overlayPlayButton.alpha = 0;
			_overlayPlayButton.mouseEnabled = false;
			addChild(_overlayPlayButton);
		};
		// Resize Controls
		private function resizeControls():void {
			_overlayPlayButton.resize();
			if (_controlPanel) _controlPanel.resize();
		};
		// Resize Video
		private function resizeVideo():void {
			var sw:int = Math.round(stage.stageWidth);
			var sh:int = Math.round(stage.stageHeight);
			var param:String = root.loaderInfo.parameters.maintainAspectRatio;
			if (param == null || getBoolean(param)) {
				var vw:int = Math.round(_video.videoWidth);
				var vh:int = Math.round(_video.videoHeight);
				var ratio:Number = vw / vh;
				// resize while maintaining aspect ratio
				if (sw / ratio < sh) {
					_video.width = sw;
					_poster.width = sw;
					_video.height = sw / ratio;
					_poster.height = sw / ratio;
				} else {
					_video.height = sh;
					_poster.height = sh;
					_video.width = sh * ratio;
					_poster.width = sh * ratio;
				}
				// reposition
				_video.x = sw / 2 - _video.width / 2;
				_poster.x = sw / 2 - _poster.width / 2;
				_video.y = sh / 2 - _video.height / 2;
				_poster.y = sh / 2 - _poster.height / 2;
			} else {
				// simple resize
				_video.width = sw;
				_poster.width = sw;
				_video.height = sh;
				_poster.height = sh;
			}
		};
		// Seek Start
		private function seekStart():void {
			addEventListener(Event.ENTER_FRAME, updateSeekKnob);
		};
		// Seek Stop
		private function seekStop():void {
			removeEventListener(Event.ENTER_FRAME, updateSeekKnob);
		};
		// Update Seek Knob
		private function updateSeekKnob(evt:Event):void {
			_seekSlider.seekValue = _stream.time / _duration;
		};

		// EVENT HANDLERS
		// onInit
		private function onInit(evt:Event):void {
			// Output DEBUGGING
			_output = new TextField();
			_output.background = true;
			_output.selectable = false;
			_output.autoSize = TextFieldAutoSize.LEFT;
			var fmt:TextFormat = new TextFormat();
			fmt.color = 0xFF0000;
			fmt.size = 32;
			_output.defaultTextFormat = fmt;
			//addChild(_output);
			// Prep
			this.opaqueBackground = 0x000000;
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			_poster = new Loader();
			_poster.mouseEnabled = false;
			_currentFile = 0;

			// Instantiate video-related objects
			_video = new Video();
			_connection = new NetConnection();

			// External param: playlist
			var param:String = root.loaderInfo.parameters.playlist;
			//var param:String = "playlist.xml";
			if (param != null) {
				var xmlLoader:URLLoader = new URLLoader();
				var xmlReq:URLRequest = new URLRequest(param);
				xmlLoader.load(xmlReq);
				xmlLoader.addEventListener(Event.COMPLETE, onXMLLoaded, false, 0, false);
			} else {
				_playlist = <playlist version="1" xmlns="http://xspf.org/ns/0/">
								<trackList></trackList>
							</playlist>;
				onInitContinue();
			}
		};
		// onInitContinue
		private function onInitContinue():void {
			var param:String;
			var file:String;
			var poster:String;
			var disableControls:String;
			var track:String;
			var node:XML;

			// External param: video (single file to play)
			param = root.loaderInfo.parameters.video;
			if (param != null) {
				file = param;
			} else {
				// For testing ...
				if (Capabilities.playerType == "StandAlone" || Capabilities.playerType == "External") {
					file = "test.flv";
				}
			}
			// External param: poster (stand-in image)
			param = root.loaderInfo.parameters.poster;
			poster = (param) ? param : "";
			// External param: disableControls (per-video option)
			param = root.loaderInfo.parameters.disableControls;
			disableControls = (getBoolean(param)) ? param : "";

			// Prep playlist track-related nodes
			track  = "<track>";
			track +=   "<location>" + file + "</location>";
			track +=   "<image>" + poster + "</image>";
			track +=   "<extension>";
			track +=     "<options disableControls=\"" + disableControls + "\" />";
			track +=   "</extension>";
			track += "</track>";
			node   = new XML(track);

			// If playlist already exists, prepend the single video ...
			_ns = new Namespace(_playlist.namespace());
			default xml namespace = _ns;
			if (_playlist.trackList.children().length() > 0) {
				//  ... without duplication ...
				if (file != null && !playlistContainsFile(file)) {
					_playlist.trackList.prependChild(node);
				}
			} else {
				// ... otherwise, append the single video,
				// creating a playlist of one
				_playlist.trackList.appendChild(node);
			}
			// Continue instantiating video-related objects
			file = _playlist.trackList.track[0].location.toString();
			if (file == null) return;
			else connect(file);
			_stream = new NetStream(_connection);
			_video.attachNetStream(_stream);

			// Handle video-related events
			var listener:Object = new Object();
			listener.onMetaData = onMetaData;
			_stream.client = listener;
			_stream.addEventListener(NetStatusEvent.NET_STATUS, onStatus, false, 0, false);

			// Add video and poster to display list,
			// set volume, load,
			// then build controls
			_videoContainer = new Sprite();
			_videoContainer.addChild(_video);
			addChild(_videoContainer);
			addChild(_poster);
			//addChild(_output);
			setVolume(parseFloat(root.loaderInfo.parameters.volume));
			if (getBoolean(root.loaderInfo.parameters.uiAutoHide)) {
				_uiHideTimer = new Timer(1200, 1);
			}
			buildControls();
			load(_playlist..track[_currentFile]);

			// Housekeeping
			this.removeEventListener(Event.ADDED_TO_STAGE, onInit);
			_videoContainer.addEventListener(MouseEvent.CLICK, onTogglePlay, false, 0, false);
			_poster.contentLoaderInfo.addEventListener(Event.COMPLETE, onPosterLoaded, false, 0, false);
			stage.addEventListener(Event.RESIZE, onResize, false, 0, false);
			if (getBoolean(root.loaderInfo.parameters.uiAutoHide)) {
				_uiHideTimer.addEventListener(TimerEvent.TIMER, onHideControls, false, 0, false);
				stage.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverStage, false, 0, false);
				stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeaveStage, false, 0, false);
			}
			onResize();
		};
		// onXMLLoaded
		private function onXMLLoaded(evt:Event):void {
			_playlist = XML(evt.target.data);
			//_ns = new Namespace(_playlist.namespace());
			onInitContinue();
		}
		// onMetaData
		private function onMetaData(evt:Object):void {
			_duration = evt.duration;
			onResize();
		}
		// onStatus
		private function onStatus(evt:Object):void {
			if (evt.info.code == "NetStream.Play.Stop") {
				_isPlaying = false;
				seekStop();
				if (getBoolean(root.loaderInfo.parameters.loop)) {
					loadNext();
				} else {
					_replay = true;
					if (_playPauseButton) _playPauseButton.toggle(true);
					_overlayPlayButton.show();
				}
			}
		};
		// onLoadStream
		private function onLoadStream(evt:Event):void {
			var val:Number = _stream.bytesLoaded / _stream.bytesTotal;
			if (_seekSlider) {
				if (val < 1) {
					_seekSlider.progressValue = val;
					_output.text = val.toString();
				} else {
					_seekSlider.progressValue = 1;
					_output.text = "";
					removeEventListener(Event.ENTER_FRAME, onLoadStream);
				}
			}
		};
		// onResize
		private function onResize(evt:Event = null):void {
			resizeVideo();
			resizeControls();
		};
		// onTogglePlay
		private function onTogglePlay(evt:MouseEvent):void {
			if (_replay) {
				_replay = false;
				_stream.seek(0);
				_isPlaying = true;
				if (_seekSlider) seekStart();
				if (_playPauseButton) _playPauseButton.toggle(false);
				_overlayPlayButton.hide();
			} else {
				if (_isPlaying) {
					_stream.pause();
					if (_seekSlider) seekStop();
					if (_playPauseButton) _playPauseButton.toggle(true);
					_overlayPlayButton.show();
				} else {
					_stream.resume();
					if (_seekSlider) seekStart();
					if (_playPauseButton) _playPauseButton.toggle(false);
					_overlayPlayButton.hide();
				}
				_isPlaying = !_isPlaying;
				_poster.unload();
			}
		};
		// onToggleFullScreen
		private function onToggleFullScreen(evt:MouseEvent):void {
			if (stage.displayState == StageDisplayState.NORMAL) {
				stage.displayState = StageDisplayState.FULL_SCREEN;
			} else {
				stage.displayState = StageDisplayState.NORMAL;
			}
			resizeControls();
		};
		// onToggleVolume
		private function onToggleVolume(evt:MouseEvent):void {
			_volumeBackup = (_volumeBackup > 0) ? _volumeBackup : 1;
			_volume = _stream.soundTransform;
			if (_volume.volume == 0) {
				_volume.volume = _volumeBackup;
				if (_volumeSlider) _volumeSlider.volume = _volumeBackup * 100;
			} else {
				_volume.volume = 0;
				if (_volumeSlider) _volumeSlider.volume = 0;
			}
			_stream.soundTransform = _volume;
			_volumeToggleButton.toggle(!_volumeSlider.volume);
		};
		// onVolumeChange
		private function onVolumeChange(evt:Event):void {
			setVolume(_volumeSlider.volume);
		};
		// onSeekMouseDown
		private function onSeekMouseDown(evt:MouseEvent):void {
			seekStop();
			stage.addEventListener(MouseEvent.MOUSE_UP, onSeekMouseUp);
		};
		// onSeekMouseUp
		private function onSeekMouseUp(evt:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, onSeekMouseUp);
			_stream.seek(_duration * _seekSlider.seekValue);
			seekStart();
		};
		// onMouseOverStage
		private function onMouseOverStage(evt:MouseEvent):void {
			if (getBoolean(root.loaderInfo.parameters.uiAutoHide)) {
				if (_controlPanel) {
					_uiHideTimer.stop();
					_controlPanel.show();
				}
			}
		};
		// onMouseLeaveStage
		private function onMouseLeaveStage(evt:Event):void {
			if (_controlPanel) _uiHideTimer.start();
		};
		// onControlsTimer
		private function onHideControls(evt:TimerEvent):void {
			_controlPanel.hide();
		};
		// onPosterLoaded
		private function onPosterLoaded(evt:Event):void {
			resizeVideo();
			_videoContainer.visible = true;
		};

		// UTILITIES
		// Playlist Contains File?
		private function playlistContainsFile(file:String):Boolean {
			var verdict:Boolean = false;
			var len:int = _playlist..track.length();
			for (var i:int = 0; i < len; i++) {
				if (_playlist..track[i].location == file) {
					verdict = true;
					break;
				}
			}
			return verdict;
		};
		// Get File Name
		private function getFileName(str:String, includeExtension:Boolean):String {
			var re:RegExp = /\/([\w\d]+)(\.[\w\d]{3,4})$/i;
			var result:Object = re.exec(str);
			return includeExtension ? result[1] + result[2] : result[1];
		};
		// Get File Path
		private function getFilePath(str:String):String {
			return str.substr(0, str.lastIndexOf("/"))
		};
		// Is HTTP Request?
		private function isHTTPRequest(str:String):Boolean {
			// Is HTTP if URL fails to contain
			// rtmp, rtmpe, rtmps, rtmpt, or rtmpte
			var re:RegExp = /rtmp([es]|te?)?:\/\//i;
			var result:Object = re.exec(str);
			return (result == null);
		};
		// Get Boolean
		private function getBoolean(str:String):Boolean {
			return (str == "true") ? true : false;
		};
		// Get UI Colors
		private function getColorsFromParam(str:String):Array {
			var re:RegExp = /(?:#|0x?)((?:[a-f0-9]{2}){3})/i;
			var result:Object;
			var arr:Array = str.split("|");
			var len:int = arr.length;
			for (var i:int = 0; i < len; i++) {
				result = re.exec(arr[i]);
				arr[i] = parseInt("0x" + result[1]);
			}
			return arr;
		};
		// Min Version Is?
		private function minVersionIs(str:String):Boolean {
			var verdict:Boolean = false;
			var re:RegExp = /[^\d]*(\d+)[,.](\d+)[,.](\d+)[,.](\d+)/;
			var minRequired:Object = re.exec(str);
			var installed:Object = re.exec(Capabilities.version);
			if (parseInt(installed[1]) > parseInt(minRequired[1])) verdict = true;
			else if (
				parseInt(installed[1]) == parseInt(minRequired[1]) &&
				parseInt(installed[3]) >= parseInt(minRequired[3])
			) verdict = true;
			return verdict;
		}
	};
};
