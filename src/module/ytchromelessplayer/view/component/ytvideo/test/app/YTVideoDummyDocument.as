package module.ytchromelessplayer.view.component.ytvideo.test.app
{
	import com.bit101.components.PushButton;

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import module.ytchromelessplayer.view.component.ytvideo.view.YTVideo;

	[SWF(frameRate="30", width="640", height="360")]
	public class YTVideoDummyDocument extends Sprite
	{
		private var video : YTVideo;

		public function YTVideoDummyDocument()
		{
			video = new YTVideo();
			addChild(video);
			video.width = 320;
			video.scaleY = video.scaleX;
			video.x = video.y = 100;
			video.start("oN0tFgLcp4g", true, true);
			new PushButton(stage, 10, 10, "togglePause", togglePause);
			new PushButton(stage, 10, 40, "toggleMute", toggleMute);
		}

		public function togglePause(e : MouseEvent) : void
		{
			video.togglePause();
		}

		public function toggleMute(e : MouseEvent) : void
		{
			video.toggleMute();
		}
	}
}