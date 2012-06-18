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
	
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	
	import module.ytchromelessplayer.YTChromelessPlayerConstants;
	import module.ytchromelessplayer.controller.events.YTChromelessPlayerEvent;
	import module.ytchromelessplayer.view.YTChromelessPlayer;
	import module.ytchromelessplayer.view.component.PlayerSkinAdapter;
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
		private var _isBuffering:Boolean = false;

		// --------------------------------------------------------------------------
		//
		// Override methods
		//
		// --------------------------------------------------------------------------
		override public function onRegister() : void
		{
			view.init();
			if(!view.skinSwfUrl)
			{
				initSkin();
				return;
			}
			var loader:Loader = new Loader();
			var info:LoaderInfo = loader.contentLoaderInfo;
			eventMap.mapListener(info, ProgressEvent.PROGRESS, loadSwfProgressHandler, ProgressEvent);
			eventMap.mapListener(info, IOErrorEvent.IO_ERROR, loadSwfIOErorrHandler, ProgressEvent);
			eventMap.mapListener(info, IOErrorEvent.DISK_ERROR, loadSwfIOErorrHandler, ProgressEvent);
			eventMap.mapListener(info, IOErrorEvent.NETWORK_ERROR, loadSwfIOErorrHandler, ProgressEvent);
			eventMap.mapListener(info, IOErrorEvent.VERIFY_ERROR, loadSwfIOErorrHandler, ProgressEvent);
			eventMap.mapListener(info, Event.COMPLETE, loadSwfCompleteHandler, Event);
			loader.load(new URLRequest(view.skinSwfUrl), new LoaderContext(false, ApplicationDomain.currentDomain));
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
//			view.maskMap[view.skin.contents.seekBar.buffer].scaleX = view.video.bufferRate;
		}

		private function updateSeek() : void
		{
			if (isSeekBtnDrag) return;
			if(_isBuffering){return;}
			var _scale : Number = view.video.currentTime / view.video.totalTime;
			
			switch(view.skinType)
			{
				case YTChromelessPlayerConstants.SKIN_TYPE_1:
				{
					view.skin.contents.seekBar.btn.x = _scale * (view.skin.contents.seekBar.base.width - view.skin.contents.seekBar.btn.width / 2) + view.skin.contents.seekBar.btn.width / 2;
					break;
				}
					
				case YTChromelessPlayerConstants.SKIN_TYPE_2:
				{
					view.skin.contents.seekBar.btn.x = _scale * view.skin.contents.seekBar.base.width;
					break;
				}
					
				default:
				{
					view.skin.contents.seekBar.btn.x = _scale * view.skin.contents.seekBar.base.width;
					break;
				}
			}

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
		
		private function playerReadyComplete():void
		{
			var screenX : int = view.skin.contents.screen.width;
			var screenY : int = view.skin.contents.screen.height;
			view.video.setSize(screenX, screenY);
			
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
			seekTimer = new Timer(33.3333, 0);
			bufferTimer = new Timer(33.3333, 0);
			eventMap.mapListener(seekTimer, TimerEvent.TIMER, seekTimerHandler, TimerEvent);
			eventMap.mapListener(bufferTimer, TimerEvent.TIMER, bufferTimerHandler, TimerEvent);
			eventMap.mapListener(view.seekBarClickableSpr, MouseEvent.MOUSE_DOWN, seekBarMouseDownHandler, MouseEvent);
			
			//mute
			eventMap.mapListener(view.video, YTVideoEvent.CHANGE_MUTE, changeMuteHandler, YTVideoEvent);
			
			eventMap.mapListener(view.skin.contents.seekBar.btn, MouseEvent.MOUSE_DOWN, seekBarBtnMouseDownHandler, MouseEvent);
			view.addChild(view.skin);
		}
		
		private function initSkin():void
		{
			var skinSWF:MovieClip = new (getDefinitionByName(YTChromelessPlayerConstants.SKIN_CLASS))();
			eventMap.mapListener(skinSWF, Event.EXIT_FRAME, skinSWFExitHandler, Event);
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
			e.updateAfterEvent()
			updateSeek();
		}
		
		private function changeMuteHandler(e:YTVideoEvent):void
		{
			view.dispatchEvent(new YTChromelessPlayerEvent(YTChromelessPlayerEvent.CHANGE_MUTE, e.body));
		}

		private function bufferTimerHandler(e : TimerEvent) : void
		{
			updateBuffer();
			if (view.video.bufferRate >= 1)
			{
				bufferTimer.stop();
			}
			if(_isBuffering){
				//trace(view.video.bytesLoaded, "bytesLoaded");
				if(view.video.bytesLoaded > 5000000){
					e.updateAfterEvent();
					var target : MovieClip = view.skin.contents.seekBar.btn;
					var time:Number = view.video.totalTime * (target.x - target.width / 2) / (view.skin.contents.seekBar.base.width - target.width);
					if(time < 0){
						time = 0;
					}
					else if(time > view.video.totalTime){
						time = view.video.totalTime - 0.3;
					}
					view.video.seek(time);
					_isBuffering = false;
				}
			}
		}

		protected function playerReadyHandler(event : YTVideoEvent) : void
		{
			view.video.removeEventListener(YTVideoEvent.PLAYER_READY, playerReadyHandler);
			playerReadyComplete();
		}

		private function seekBarBtnMouseDownHandler(e : MouseEvent) : void
		{
			isSeekBtnDrag = true;
			eventMap.mapListener(view.stage, MouseEvent.MOUSE_UP, seekBarBtnMouseUpHandler, MouseEvent);
			//eventMap.mapListener(view.stage, MouseEvent.MOUSE_MOVE, seekBarBtnMouseMoveHandler, MouseEvent);
			eventMap.mapListener(view.stage, Event.ENTER_FRAME, seekBarBtnMouseMoveHandler, Event);
			var target : Sprite = view.skin.contents.seekBar.btn;
			
			
			switch(view.skinType)
			{
				case YTChromelessPlayerConstants.SKIN_TYPE_1:
				{
					target.startDrag(false, new Rectangle(target.width / 2, target.y, view.skin.contents.seekBar.base.width - target.width, 0));
					break;
				}
					
				case YTChromelessPlayerConstants.SKIN_TYPE_2:
				{
					target.startDrag(false, new Rectangle(0, target.y, view.skin.contents.seekBar.base.width, 0));
					break;
				}
					
				default:
				{
					target.startDrag(false, new Rectangle(0, target.y, view.skin.contents.seekBar.base.width, 0));
					break;
				}
			}

			
			
			view.video.pause();
		}

		private function seekBarBtnMouseMoveHandler(e : Event) : void
		{
			var target : MovieClip = view.skin.contents.seekBar.btn;
			view.maskMap[view.skin.contents.seekBar.seek].width = target.x;
			
			var time:Number = view.video.totalTime * (target.x - target.width / 2) / (view.skin.contents.seekBar.base.width - target.width);//TODO あああ
			if(time < 0){
				time = 0;
			}
			else if(time > view.video.totalTime){
				time = view.video.totalTime - 0.3;
			}
		}

		private function seekBarBtnMouseUpHandler(e : MouseEvent) : void
		{

			eventMap.unmapListener(view.stage, MouseEvent.MOUSE_UP, seekBarBtnMouseUpHandler, MouseEvent);
			//eventMap.unmapListener(view.stage, MouseEvent.MOUSE_MOVE, seekBarBtnMouseMoveHandler, MouseEvent);
			eventMap.unmapListener(view.stage, Event.ENTER_FRAME, seekBarBtnMouseMoveHandler, Event);
			var target : MovieClip = view.skin.contents.seekBar.btn;
			target.stopDrag();
			//view.video.seek(view.video.totalTime * (target.x - target.width / 2) / (view.skin.contents.seekBar.base.width - target.width));
			view.video.pause();
			var time:Number = view.video.totalTime * (target.x - target.width / 2) / (view.skin.contents.seekBar.base.width - target.width);
			if(time < 0){
				time = 0;
			}
			else if(time > view.video.totalTime){
				time = view.video.totalTime - 0.3;
			}
			
			view.video.seek(time);
			
			view.video.play();
			isSeekBtnDrag = false;
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
					_isBuffering = true;
					bufferTimer.start();
					updateSeek();
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
					updateSeek();
					// trace(playerState,"PLAYING");
					seekTimer.start();
					updatePlayPauseBtn(true);
					_isBuffering = false;
					break;
				case PlayerState.UNSTARTED:
					// trace(playerState,"UNSTARTED");
					seekTimer.stop();
					reset();
					updatePlayPauseBtn(false);
					break;
			}
			view.dispatchEvent(new YTChromelessPlayerEvent(YTChromelessPlayerEvent.UPDATE_STATUS, playerState));
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
		
		
		private function loadSwfCompleteHandler(e:Event):void
		{
			var info:LoaderInfo = e.target as LoaderInfo;
			eventMap.unmapListener(info, ProgressEvent.PROGRESS, loadSwfProgressHandler, ProgressEvent);
			eventMap.unmapListener(info, IOErrorEvent.IO_ERROR, loadSwfIOErorrHandler, ProgressEvent);
			eventMap.unmapListener(info, IOErrorEvent.DISK_ERROR, loadSwfIOErorrHandler, ProgressEvent);
			eventMap.unmapListener(info, IOErrorEvent.NETWORK_ERROR, loadSwfIOErorrHandler, ProgressEvent);
			eventMap.unmapListener(info, IOErrorEvent.VERIFY_ERROR, loadSwfIOErorrHandler, ProgressEvent);
			eventMap.unmapListener(info, Event.COMPLETE, loadSwfCompleteHandler, Event);
			
			initSkin();
		}
		
		
		
		private function loadSwfIOErorrHandler(e:IOErrorEvent):void
		{
			switch(e.type)
			{
				case IOErrorEvent.DISK_ERROR:
				{
					trace(e);
					break;
				}
					
				case IOErrorEvent.IO_ERROR:
				{
					trace(e);
					break;
				}
					
				case IOErrorEvent.NETWORK_ERROR:
				{
					trace(e);
					break;
				}
					
				case IOErrorEvent.VERIFY_ERROR:
				{
					trace(e);
					break;
				}
			}
		}
		
		private function loadSwfProgressHandler(e:ProgressEvent):void
		{
			
		}
		
		private function skinSWFExitHandler(e:Event):void
		{
			var skinSWF:MovieClip = e.target as MovieClip;
			eventMap.unmapListener(skinSWF, Event.EXIT_FRAME, skinSWFExitHandler);
			view.skinType = skinSWF.skinType;
			view.skin = new PlayerSkinAdapter(skinSWF);
			view.video.addEventListener(YTVideoEvent.PLAYER_READY, playerReadyHandler);
		}
	}
}


