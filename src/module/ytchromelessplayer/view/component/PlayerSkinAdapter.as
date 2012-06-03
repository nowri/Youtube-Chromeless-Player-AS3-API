package module.ytchromelessplayer.view.component
{
	public class PlayerSkinAdapter extends PlayerSkin
	{
		private var _contents : PlayerContents;

		public function PlayerSkinAdapter()
		{
			_contents = new PlayerContents(content);
		}

		public function get contents() : PlayerContents
		{
			return _contents;
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