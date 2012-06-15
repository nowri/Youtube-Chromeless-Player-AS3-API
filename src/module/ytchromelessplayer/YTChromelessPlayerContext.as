package module.ytchromelessplayer
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;

	import module.ytchromelessplayer.view.YTChromelessPlayer;
	import module.ytchromelessplayer.view.mediator.YTChromelessPlayerBtnHoverMediator;
	import module.ytchromelessplayer.view.mediator.YTChromelessPlayerMediator;

	import org.robotlegs.mvcs.Context;

	public class YTChromelessPlayerContext extends Context
	{
		public function YTChromelessPlayerContext(contextView : DisplayObjectContainer = null, autoStartup : Boolean = true)
		{
			super(contextView, autoStartup);
		}

		override public function startup() : void
		{
			// view
			mediatorMap.mapView(YTChromelessPlayer, YTChromelessPlayerMediator);
			mediatorMap.mapView(MovieClip, YTChromelessPlayerBtnHoverMediator, null, false);
			
			super.startup();
		}
	}
}

