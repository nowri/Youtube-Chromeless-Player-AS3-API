package module.ytchromelessplayer.view.component
{
	import flash.display.MovieClip;

	public class PlayerSkinAdapter extends MovieClip
	{
		private var _contents : PlayerContents;
		private var skin : MovieClip;

		public function PlayerSkinAdapter(skin:MovieClip)
		{
			this.skin = skin.content;
			_contents = new PlayerContents(this.skin);
		}

		public function get contents() : PlayerContents
		{
			return _contents;
		}
		
		public function get content() : MovieClip
		{
			return skin;
		}
	}
}
import flash.display.MovieClip;

class PlayerContents
{
	public var seekBar : MovieClip;
	public var screen : MovieClip;
	public var btnSound : MovieClip;
	public var btnBack : MovieClip;
	public var btnPlayPause : MovieClip;

	public function PlayerContents(mc : MovieClip)
	{
		seekBar = mc.seekBar;
		screen = mc.screen;
		btnSound = mc.btnSound;
		btnBack = mc.btnBack;
		btnPlayPause = mc.btnPlayPause;
	}
}