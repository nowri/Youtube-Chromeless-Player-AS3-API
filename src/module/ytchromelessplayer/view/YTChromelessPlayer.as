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

	import module.ytchromelessplayer.YTChromelessPlayerContext;
	import module.ytchromelessplayer.controller.events.YTChromelessPlayerEvent;
	import module.ytchromelessplayer.view.component.PlayerSkin;
	import module.ytchromelessplayer.view.component.PlayerSkinAdapter;
	import module.ytchromelessplayer.view.component.ytvideo.view.YTVideo;

	[Event(name="ADD_LISTENER_MOUSE_HOVER", type="module.ytchromelessplayer.controller.events.YTChromelessPlayerEvent")]
	[SWF(frameRate="30", width="800", height="600")]
	public class YTChromelessPlayer extends Sprite
	{
		// --------------------------------------------------------------------------
		//
		// Constructor
		//
		// --------------------------------------------------------------------------
		public function YTChromelessPlayer(screen_mouse_enable : Boolean = false)
		{
			screenMouseEnable = screen_mouse_enable;
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
		private var context : YTChromelessPlayerContext;

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
			skin = new PlayerSkinAdapter();
			skin.addChild(video);
		}

		public function initSkin() : void
		{
			var screenX : int = skin.contents.screen.width;
			var screenY : int = skin.contents.screen.height;

			while (skin.contents.screen.length)
			{
				skin.contents.screen.removeChild(skin.contents.screen.getChildAt(0));
			}
			skin.contents.screen.addChild(video);
			video.width = screenX;
			video.height = screenY;

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
		}

		public function reset() : void
		{
			maskMap[skin.contents.seekBar.seek].scaleX = maskMap[skin.contents.seekBar.buffer].scaleX = 0;
			skin.contents.seekBar.btn.x = skin.contents.seekBar.btn.width / 2;
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
