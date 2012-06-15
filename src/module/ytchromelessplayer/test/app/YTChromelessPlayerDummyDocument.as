package module.ytchromelessplayer.test.app
{
	import com.bit101.components.PushButton;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import module.ytchromelessplayer.controller.events.YTChromelessPlayerEvent;
	import module.ytchromelessplayer.view.YTChromelessPlayer;

	[SWF(frameRate="30", width="800", height="600")]
	public class YTChromelessPlayerDummyDocument extends Sprite
	{
		private var player : YTChromelessPlayer;

		public function YTChromelessPlayerDummyDocument()
		{
//			player = new YTChromelessPlayer("playerskin1.swf", true);
			player = new YTChromelessPlayer("playerskin2.swf", true);
			
			player.x = player.y = 100;
			addChild(player);
			new PushButton(stage, 10, 10, "play", play);
			new PushButton(stage, 10, 40, "stop", stop);
			player.play("9_Yx-4zeQPI", true, true);
			player.addEventListener(YTChromelessPlayerEvent.CHANGE_MUTE, ytChromelessPlayerEventHandler);
			player.addEventListener(YTChromelessPlayerEvent.READY_COMPLETE_PLAYER, ytChromelessPlayerEventHandler);
			player.addEventListener(YTChromelessPlayerEvent.UPDATE_STATUS, ytChromelessPlayerEventHandler);
		}
		
		protected function ytChromelessPlayerEventHandler(e:YTChromelessPlayerEvent):void
		{
			trace(e.type,e.body);
		}
		
		public function play(e : MouseEvent) : void
		{
			player.play("9_Yx-4zeQPI", true, true);
		}

		public function stop(e : MouseEvent) : void
		{
			player.stop();
		}
	}
}