// --------------------------------------------------------------------------
//
//
// @author : nowri.ka
// @date : 2012/05/31
//
// --------------------------------------------------------------------------
package module.ytchromelessplayer.view.component.ytvideo.view
{
	import com.google.youtube.examples.helper.core.PlaybackQuality;
	import com.google.youtube.examples.helper.core.PlayerEvent;
	import com.google.youtube.examples.helper.core.PlayerLoader;
	import com.google.youtube.examples.helper.core.PlayerState;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import module.ytchromelessplayer.view.component.ytvideo.controller.events.YTVideoEvent;
	
	
	[Event(name="UPDATE_STATE", type="module.ytchromelessplayer.view.component.ytvideo.controller.events.YTVideoEvent")]
	[Event(name="PLAYER_READY", type="module.ytchromelessplayer.view.component.ytvideo.controller.events.YTVideoEvent")]
	[Event(name="CHANGE_MUTE", type="module.ytchromelessplayer.view.component.ytvideo.controller.events.YTVideoEvent")]
	public class YTVideo extends Sprite
	{
		// --------------------------------------------------------------------------
		//
		// Class constants
		//
		// --------------------------------------------------------------------------
		private static const VIDEO_SIZE : Vector.<int>=Vector.<int>([640, 360]);
		private static const BG_COLOR : uint = 0x000000;
		
		// --------------------------------------------------------------------------
		//
		// Constructor
		//
		// --------------------------------------------------------------------------
		public function YTVideo(screen_mouse_enable : Boolean = false, video_size:Vector.<int>=null)
		{
			screenMouseEnable = screen_mouse_enable;
			videoSize = (!video_size)? VIDEO_SIZE:video_size;
			init();
		}
		
		// --------------------------------------------------------------------------
		//
		// Variables
		//
		// --------------------------------------------------------------------------
		private var ytPlayerHelper : PlayerLoader;
		private var isPlayable : int = 0;
		private var videoId : String;
		private var isLoop : Boolean;
		private var autoStart : Boolean;
		private var screenMouseEnable : Boolean;
		private var videoSize:Vector.<int>;
		
		// --------------------------------------------------------------------------
		//
		// Accessors(a-z, getter -> setter)
		//
		// --------------------------------------------------------------------------
		// ----------------------------------
		// bufferRate
		// ----------------------------------
		public function get bytesLoaded():Number{return ytPlayerHelper.player.getVideoBytesLoaded();}
		public function get bytesTotal():Number{return ytPlayerHelper.player.getVideoBytesTotal();}
		public function get bytesStart():Number{return ytPlayerHelper.player.getVideoStartBytes();}
		
		public function get bufferRate() : Number
		{
			return ytPlayerHelper.player.getVideoBytesLoaded() / ytPlayerHelper.player.getVideoBytesTotal();
		}
		
		// ----------------------------------
		// currentTime
		// ----------------------------------
		public function get currentTime() : Number
		{
			return ytPlayerHelper.player.getCurrentTime();
		}
		
		// ----------------------------------
		// isMute
		// ----------------------------------
		public function get isMute() : Boolean
		{
			return ytPlayerHelper.player.isMuted();
		}
		
		public function set isMute(bool : Boolean) : void
		{
			if (bool)
			{
				ytPlayerHelper.player.mute();
			}
			else
			{
				ytPlayerHelper.player.unmute();
			}
			
			dispatchEvent(new YTVideoEvent(YTVideoEvent.CHANGE_MUTE, bool));
		}
		
		// ----------------------------------
		// totalTime
		// ----------------------------------
		public function get totalTime() : Number
		{
			return ytPlayerHelper.player.getDuration();
		}
		
		// ----------------------------------
		// state
		// ----------------------------------
		public function get state() : Number
		{
			return ytPlayerHelper.player.getPlayerState();
		}
		
		// ----------------------------------
		// volume
		// ----------------------------------
		public function get volume() : Number
		{
			return ytPlayerHelper.player.getVolume();
		}
		
		public function set volume(value : Number) : void
		{
			ytPlayerHelper.player.setVolume(value);
		}
		
		// --------------------------------------------------------------------------
		//
		// Methods
		//
		// --------------------------------------------------------------------------
		// ----------------------------------
		// Public API
		// ----------------------------------
		public function start(video_id : String, loop : Boolean, auto_start : Boolean) : void
		{
			videoId = video_id;
			isLoop = loop;
			autoStart = auto_start;
			playable();
		}
		
		public function setSize(w:int, h:int) : void
		{
			var g : Graphics = graphics;
			g.clear();
			g.beginFill(BG_COLOR);
			g.drawRect(0, 0, w, h);
			g.endFill();
			ytPlayerHelper.player.setSize(w,h);
		}
		
		public function togglePause() : void
		{
			switch(ytPlayerHelper.player.getPlayerState())
			{
				case PlayerState.CUED:
				case PlayerState.PAUSED:
				{
					ytPlayerHelper.player.playVideo();
					break;
				}
				case PlayerState.PLAYING:
				{
					ytPlayerHelper.player.pauseVideo();
					break;
				}
					
			}
		}
		
		public function pause() : void
		{
			switch(ytPlayerHelper.player.getPlayerState())
			{
				case PlayerState.PLAYING:
				{
					ytPlayerHelper.player.pauseVideo();
					break;
				}
			}
		}
		
		public function play() : void
		{
			// switch(ytPlayerHelper.player.getPlayerState())
			// {
			// case PlayerState.PAUSED:
			// {
			ytPlayerHelper.player.playVideo();
			// break;
			// }
			// }
		}
		
		public function stop() : void
		{
			ytPlayerHelper.player.stopVideo();
		}
		
		public function toggleMute() : void
		{
			isMute = !isMute;
		}
		
		public function seek(num : Number) : void
		{
			ytPlayerHelper.player.seekTo(num);
		}
		
		public function destroy() : void
		{
			// TODO 未検証
			ytPlayerHelper.removeEventListener(PlayerEvent.STATE_CHANGE, onPlayerStateChange);
			ytPlayerHelper.removeEventListener(PlayerEvent.ERROR, onPlayerError);
			ytPlayerHelper.unload();
		}
		
		// ----------------------------------
		// internal methods
		// ----------------------------------
		private function playable() : void
		{
			if (++isPlayable >= 2)
			{
				if (autoStart)
				{
					ytPlayerHelper.player.loadVideoById(videoId, 0, PlaybackQuality.MEDIUM);
				}
				else
				{
					ytPlayerHelper.player.cueVideoById(videoId, 0, PlaybackQuality.MEDIUM);
				}
			}
		}
		
		private function init() : void
		{
			mouseChildren = mouseEnabled = screenMouseEnable;
			
			ytPlayerHelper = new PlayerLoader();
			ytPlayerHelper.addEventListener(PlayerEvent.PLAYER_IS_READY, onPlayerReady);
			ytPlayerHelper.loadChromelessVideoPlayer();
		}
		
		// --------------------------------------------------------------------------
		//
		// Event Handler
		//
		// --------------------------------------------------------------------------
		private function onPlayerReady(event : PlayerEvent) : void
		{
			addChild(ytPlayerHelper.player);
			
			ytPlayerHelper.removeEventListener(PlayerEvent.PLAYER_IS_READY, onPlayerReady);
			ytPlayerHelper.player.addEventListener(PlayerEvent.STATE_CHANGE, onPlayerStateChange);
			ytPlayerHelper.player.addEventListener(PlayerEvent.ERROR, onPlayerError);
			setSize(videoSize[0], videoSize[1]);
			dispatchEvent(new YTVideoEvent(YTVideoEvent.PLAYER_READY));
			playable();
		}
		
		private function onPlayerError(event : Event) : void
		{
			trace("info", "error: ", event);
		}
		
		private function onPlayerStateChange(event : Event) : void
		{
			var youtubeEvent : Object = event;
			var playerState : Number = Number(youtubeEvent.data);
			switch (playerState)
			{
				case PlayerState.BUFFERING:
					// trace(playerState,"BUFFERING");
					break;
				case PlayerState.CUED:
					// trace(playerState,"CUED");
					break;
				case PlayerState.ENDED:
					// trace(playerState,"ENDED");
					if (isLoop) ytPlayerHelper.player.playVideo();
					break;
				case PlayerState.PAUSED:
					// trace(playerState,"PAUSED");
					break;
				case PlayerState.PLAYING:
					// trace(playerState,"PLAYING");
					// trace(currentTime, totalTime);
					break;
				case PlayerState.UNSTARTED:
					// trace(playerState,"UNSTARTED");
					break;
			}
			dispatchEvent(new YTVideoEvent(YTVideoEvent.UPDATE_STATUS, playerState));
		}
	}
}

