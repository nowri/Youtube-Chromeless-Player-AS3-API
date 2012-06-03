// --------------------------------------------------------------------------
//
//
// @author : nowri.ka
// @date : 2012/06/03
//
// --------------------------------------------------------------------------
package module.ytchromelessplayer.view.mediator
{
	import com.google.youtube.examples.helper.core.PlayerState;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;

	import module.ytchromelessplayer.controller.events.YTChromelessPlayerEvent;
	import module.ytchromelessplayer.view.YTChromelessPlayer;
	import module.ytchromelessplayer.view.component.ytvideo.controller.events.YTVideoEvent;

	import org.robotlegs.mvcs.Mediator;

	public class YTChromelessPlayerMediator extends Mediator
	{
		// --------------------------------------------------------------------------
		//
		// Constructor
		//
		// --------------------------------------------------------------------------
		public function YTChromelessPlayerMediator()
		{
		}

		// --------------------------------------------------------------------------
		//
		// Variables
		//
		// --------------------------------------------------------------------------
		[Inject]
		public var view : YTChromelessPlayer;
		private var seekTimer : Timer;
		private var bufferTimer : Timer;
		private var isSeekBtnDrag : Boolean;

		// --------------------------------------------------------------------------
		//
		// Override methods
		//
		// --------------------------------------------------------------------------
		override public function onRegister() : void
		{
			view.init();
			view.video.addEventListener(YTVideoEvent.PLAYER_READY, playerReadyHandler);
		}

		// --------------------------------------------------------------------------
		//
		// Methods
		//
		// --------------------------------------------------------------------------
		private function reset() : void
		{
			view.reset();
		}

		private function updateBuffer() : void
		{
			view.maskMap[view.skin.contents.seekBar.buffer].scaleX = view.video.bufferRate;
		}

		private function updateSeek() : void
		{
			if (isSeekBtnDrag) return;

			var _scale : Number = view.video.currentTime / view.video.totalTime;
			view.skin.contents.seekBar.btn.x = _scale * (view.skin.contents.seekBar.base.width - view.skin.contents.seekBar.btn.width / 2) + view.skin.contents.seekBar.btn.width / 2;
			view.maskMap[view.skin.contents.seekBar.seek].width = view.skin.contents.seekBar.btn.x;
		}

		private function updatePlayPauseBtn(bool : Boolean) : void
		{
			if (bool)
			{
				view.skin.contents.btnPlayPause.playBtn.visible = false;
				view.skin.contents.btnPlayPause.pauseBtn.visible = true;
			}
			else
			{
				view.skin.contents.btnPlayPause.playBtn.visible = true;
				view.skin.contents.btnPlayPause.pauseBtn.visible = false;
			}
		}

		// --------------------------------------------------------------------------
		//
		// Event Handler
		//
		// --------------------------------------------------------------------------
		private function setMoudeHoverListenerHandler(e : YTChromelessPlayerEvent) : void
		{
			var btn : MovieClip = e.body as MovieClip;
			mediatorMap.createMediator(btn);
		}

		private function seekTimerHandler(e : TimerEvent) : void
		{
			updateSeek();
		}

		private function bufferTimerHandler(e : TimerEvent) : void
		{
			updateBuffer();
			if (view.video.bufferRate >= 1)
			{
				bufferTimer.stop();
			}
		}

		protected function playerReadyHandler(event : YTVideoEvent) : void
		{
			view.video.removeEventListener(YTVideoEvent.PLAYER_READY, playerReadyHandler);

			// set btn hover
			view.addEventListener(YTChromelessPlayerEvent.ADD_LISTENER_MOUSE_HOVER, setMoudeHoverListenerHandler);
			view.initSkin();
			view.removeEventListener(YTChromelessPlayerEvent.ADD_LISTENER_MOUSE_HOVER, setMoudeHoverListenerHandler);

			// update status
			eventMap.mapListener(view.video, YTVideoEvent.UPDATE_STATUS, updateStatudHandler, YTVideoEvent, false, 0, false);

			// btn
			eventMap.mapListener(view.skin.contents.btnSound, MouseEvent.CLICK, btnSoundMouseHandler, MouseEvent);
			view.skin.contents.btnSound.buttonMode = true;

			eventMap.mapListener(view.skin.contents.btnBack, MouseEvent.CLICK, btnBackMouseHandler, MouseEvent);
			view.skin.contents.btnBack.buttonMode = true;

			eventMap.mapListener(view.skin.contents.btnPlayPause, MouseEvent.CLICK, btnPlayPauseMouseHandler, MouseEvent);
			view.skin.contents.btnPlayPause.buttonMode = true;

			// seekbar
			view.skin.contents.seekBar.btn.buttonMode = true;
			seekTimer = new Timer(33, 0);
			bufferTimer = new Timer(33, 0);
			eventMap.mapListener(seekTimer, TimerEvent.TIMER, seekTimerHandler, TimerEvent);
			eventMap.mapListener(bufferTimer, TimerEvent.TIMER, bufferTimerHandler, TimerEvent);
			eventMap.mapListener(view.seekBarClickableSpr, MouseEvent.MOUSE_DOWN, seekBarMouseDownHandler, MouseEvent);

			eventMap.mapListener(view.skin.contents.seekBar.btn, MouseEvent.MOUSE_DOWN, seekBarBtnMouseDownHandler, MouseEvent);

			view.addChild(view.skin);
		}

		private function seekBarBtnMouseDownHandler(e : MouseEvent) : void
		{
			isSeekBtnDrag = true;
			eventMap.mapListener(view.stage, MouseEvent.MOUSE_UP, seekBarBtnMouseUpHandler, MouseEvent);
			eventMap.mapListener(view.stage, MouseEvent.MOUSE_MOVE, seekBarBtnMouseMoveHandler, MouseEvent);
			var target : Sprite = e.currentTarget as Sprite;
			target.startDrag(false, new Rectangle(target.width / 2, target.y, view.skin.contents.seekBar.base.width - target.width, 0));
			view.video.pause();
		}

		private function seekBarBtnMouseMoveHandler(e : MouseEvent) : void
		{
			var target : MovieClip = view.skin.contents.seekBar.btn;
			view.maskMap[view.skin.contents.seekBar.seek].width = view.skin.contents.seekBar.btn.x;
			view.video.seek(view.video.totalTime * (target.x - target.width / 2) / (view.skin.contents.seekBar.base.width - target.width));
		}

		private function seekBarBtnMouseUpHandler(e : MouseEvent) : void
		{
			isSeekBtnDrag = false;
			eventMap.unmapListener(view.stage, MouseEvent.MOUSE_UP, seekBarBtnMouseUpHandler, MouseEvent);
			eventMap.unmapListener(view.stage, MouseEvent.MOUSE_MOVE, seekBarBtnMouseMoveHandler, MouseEvent);
			var target : MovieClip = view.skin.contents.seekBar.btn;
			target.stopDrag();
			view.video.seek(view.video.totalTime * (target.x - target.width / 2) / (view.skin.contents.seekBar.base.width - target.width));
			view.video.play();
		}

		private function seekBarMouseDownHandler(e : MouseEvent) : void
		{
			var isPlay : Boolean = (view.video.state == PlayerState.PLAYING) ? true : false;
			var rate : Number = e.target.mouseX / e.target.width;
			view.video.pause();
			view.video.seek(view.video.totalTime * rate);
			view.video.play();
			if (!isPlay)
			{
				view.video.pause();
				updateSeek();
			}
		}

		private function updateStatudHandler(e : YTVideoEvent) : void
		{
			var playerState : Number = Number(e.body);
			switch (playerState)
			{
				case PlayerState.BUFFERING:
					// trace(playerState,"BUFFERING");
					bufferTimer.start();
					break;
				case PlayerState.CUED:
					// trace(playerState,"CUED");
					seekTimer.stop();
					updateSeek();
					updatePlayPauseBtn(false);
					break;
				case PlayerState.ENDED:
					// trace(playerState,"ENDED");
					seekTimer.stop();
					updatePlayPauseBtn(false);
					break;
				case PlayerState.PAUSED:
					// trace(playerState,"PAUSED");
					seekTimer.stop();
					updateSeek();
					updatePlayPauseBtn(false);
					break;
				case PlayerState.PLAYING:
					// trace(playerState,"PLAYING");
					seekTimer.start();
					updatePlayPauseBtn(true);
					break;
				case PlayerState.UNSTARTED:
					// trace(playerState,"UNSTARTED");
					seekTimer.stop();
					reset();
					updatePlayPauseBtn(false);
					break;
			}
		}

		private function btnPlayPauseMouseHandler(e : MouseEvent) : void
		{
			view.video.togglePause();
		}

		private function btnBackMouseHandler(e : MouseEvent) : void
		{
			var isPlay : Boolean = (view.video.state == PlayerState.PLAYING) ? true : false;
			view.video.pause();
			view.video.seek(0);
			view.video.play();
			if (!isPlay)
			{
				view.video.pause();
				updateSeek();
			}
		}

		private function btnSoundMouseHandler(e : MouseEvent) : void
		{
			view.video.toggleMute();
			switch(view.video.isMute)
			{
				case true:
				{
					view.skin.contents.btnSound.btnOn.visible = false;
					view.skin.contents.btnSound.btnOff.visible = true;
					break;
				}
				case false:
				{
					view.skin.contents.btnSound.btnOn.visible = true;
					view.skin.contents.btnSound.btnOff.visible = false;
					break;
				}
			}
		}
	}
}