// --------------------------------------------------------------------------
//
//
// @author : nowri.ka
// @date : 2012/06/01
//
// --------------------------------------------------------------------------
package module.ytchromelessplayer.view
{
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	import module.ytchromelessplayer.YTChromelessPlayerConstants;
	import module.ytchromelessplayer.YTChromelessPlayerContext;
	import module.ytchromelessplayer.controller.events.YTChromelessPlayerEvent;
	import module.ytchromelessplayer.view.component.PlayerSkinAdapter;
	import module.ytchromelessplayer.view.component.ytvideo.view.YTVideo;
	
	[Event(name="CHANGE_MUTE", type="module.ytchromelessplayer.controller.events.YTChromelessPlayerEvent")]
	[Event(name="READY_COMPLETE_PLAYER", type="module.ytchromelessplayer.controller.events.YTChromelessPlayerEvent")]
	[Event(name="UPDATE_STATUS", type="module.ytchromelessplayer.controller.events.YTChromelessPlayerEvent")]
	[Event(name="ADD_LISTENER_MOUSE_HOVER", type="module.ytchromelessplayer.controller.events.YTChromelessPlayerEvent")]
	[SWF(frameRate="30", width="800", height="600")]
	public class YTChromelessPlayer extends Sprite
	{
		// --------------------------------------------------------------------------
		//
		// Constructor
		//
		// --------------------------------------------------------------------------
		public function YTChromelessPlayer(skin_swf_url:String="", screen_mouse_enable : Boolean = false, video_size:Vector.<int>=null)
		{
			screenMouseEnable = screen_mouse_enable;
			skinSwfUrl = skin_swf_url;
			videoSize = video_size;
			context = new YTChromelessPlayerContext(this);
		}
		
		// --------------------------------------------------------------------------
		//
		// Variables
		//
		// --------------------------------------------------------------------------
		public var video : YTVideo;
		public var skin : PlayerSkinAdapter;
		public var maskMap : Dictionary = new Dictionary(true);
		public var seekBarClickableSpr : Sprite;
		public var screenMouseEnable : Boolean;
		public var skinSwfUrl:String;
		public var skinType:int;
		private var context : YTChromelessPlayerContext;
		private var videoSize:Vector.<int>;

		//--------------------------------------------------------------------------
		//
		//  Accessors(a-z, getter -> setter)
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  state
		//----------------------------------
		public function get state() : int
		{
			return video.state;
		}
		
		
		// --------------------------------------------------------------------------
		//
		// Methods
		//
		// --------------------------------------------------------------------------
		// ----------------------------------
		// Public API
		// ----------------------------------
		public function play(video_id : String, loop : Boolean, auto_start : Boolean) : void
		{
			video.start(video_id, loop, auto_start);
		}

		public function stop() : void
		{
			video.seek(0);
			video.stop();
		}
		
		public function pause() : void
		{
			video.stop();
		}
		
		public function resume() : void
		{
			video.play();
		}

		public function destroy() : void
		{
			// TODO 未検証
			video.destroy();
		}

		// ----------------------------------
		// From mediator
		// ----------------------------------
		public function init() : void
		{
			video = new YTVideo(screenMouseEnable);
		}

		public function initSkin() : void
		{
			addChild(skin.content);
			
			
			while (skin.contents.screen.length)
			{
				skin.contents.screen.removeChild(skin.contents.screen.getChildAt(0));
			}
			skin.contents.screen.addChild(video);
			setSeekBarMask(skin.contents.seekBar.seek);
			setSeekBarMask(skin.contents.seekBar.buffer);
			seekBarClickableSpr = new Sprite();
			var g : Graphics = seekBarClickableSpr.graphics;
			skin.contents.seekBar.addChildAt(seekBarClickableSpr, skin.contents.seekBar.getChildIndex(skin.contents.seekBar.btn));
			g.beginFill(0x00, 0);
			g.drawRect(0, 0, skin.contents.seekBar.base.width, skin.contents.seekBar.base.height);
			g.endFill();

			setBtnHover(skin.contents.seekBar.btn);
			setBtnHover(skin.contents.btnSound);
			setBtnHover(skin.contents.btnBack);
			setBtnHover(skin.contents.btnPlayPause);

			reset();

			var btn : MovieClip = skin.contents.btnSound;
			btn.btnOff.visible = false;

			btn = skin.contents.btnBack;

			btn = skin.contents.btnPlayPause;
			btn.pauseBtn.visible = false;
			
			dispatchEvent(new YTChromelessPlayerEvent(YTChromelessPlayerEvent.READY_COMPLETE_PLAYER));
		}

		public function reset() : void
		{
			maskMap[skin.contents.seekBar.seek].scaleX = maskMap[skin.contents.seekBar.buffer].scaleX = 0;
			
			
			switch(skinType)
			{
				case YTChromelessPlayerConstants.SKIN_TYPE_1:
				{
					skin.contents.seekBar.btn.x = skin.contents.seekBar.btn.width / 2;
					break;
				}
					
				case YTChromelessPlayerConstants.SKIN_TYPE_2:
				{
					skin.contents.seekBar.btn.x = 0;
					break;
				}
					
				default:
				{
					skin.contents.seekBar.btn.x = 0;
					break;
				}
			}
		}

		// ----------------------------------
		// Internal methods
		// ----------------------------------
		private function setSeekBarMask(mc : MovieClip) : void
		{
			if (!mc) return;
			var sh : Shape = new Shape();
			var g : Graphics = sh.graphics;
			g.beginFill(0x00);
			g.drawRect(0, 0, mc.width, mc.height);
			mc.parent.addChild(sh);
			sh.scaleX = 0;
			mc.mask = sh;
			maskMap[mc] = sh;
		}

		private function setBtnHover(mc : MovieClip) : void
		{
			if (mc.ov)
			{
				dispatchEvent(new YTChromelessPlayerEvent(YTChromelessPlayerEvent.ADD_LISTENER_MOUSE_HOVER, mc));
			}
		}
	}
}
