// --------------------------------------------------------------------------
//
//
// @author : nowri.ka
// @date : 2012/06/03
//
// --------------------------------------------------------------------------
package module.ytchromelessplayer.view.mediator
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import org.libspark.betweenas3.BetweenAS3;
	import org.libspark.betweenas3.core.easing.IEasing;
	import org.libspark.betweenas3.easing.Expo;
	import org.libspark.betweenas3.easing.Sine;
	import org.libspark.betweenas3.tweens.ITween;
	import org.robotlegs.mvcs.Mediator;

	public class YTChromelessPlayerBtnHoverMediator extends Mediator
	{
		// --------------------------------------------------------------------------
		//
		// Constructor
		//
		// --------------------------------------------------------------------------
		public function YTChromelessPlayerBtnHoverMediator()
		{
		}

		// --------------------------------------------------------------------------
		//
		// Variables
		//
		// --------------------------------------------------------------------------
		[Inject]
		public var btn : MovieClip;
		private var twHover : ITween;

		// --------------------------------------------------------------------------
		//
		// Override methods
		//
		// --------------------------------------------------------------------------
		override public function onRegister() : void
		{
			initialize();
		}

		// --------------------------------------------------------------------------
		//
		// Methods
		//
		// --------------------------------------------------------------------------
		// ----------------------------------
		// Internal methods
		// ----------------------------------
		private function initialize() : void
		{
			if (btn["hit"] && (btn["hit"]is Sprite))
			{
				btn.mouseChildren = false;
				btn.hitArea = btn["hit"];
			}

			if (btn["ov"] && (btn["ov"] is DisplayObject))
			{
				eventMap.mapListener(btn, MouseEvent.ROLL_OVER, mouseEventHandler);
				eventMap.mapListener(btn, MouseEvent.ROLL_OUT, mouseEventHandler);
				btn["ov"].alpha = 0;
			}
		}

		private function tweenHover(bool : Boolean) : void
		{
			if (twHover)
			{
				twHover.stop();
			}

			var time : Number;
			var easing : IEasing;
			var obj : Object;

			switch(bool)
			{
				case true:
				{
					time = 0.5;
					easing = Expo.easeOut;
					obj = {alpha:1};
					break;
				}
				case false:
				{
					time = 0.4;
					easing = Sine.easeIn;
					obj = {alpha:0};
					break;
				}
			}
			twHover = BetweenAS3.to(btn["ov"], obj, time, easing);
			twHover.play();
		}

		// --------------------------------------------------------------------------
		//
		// Event Handler
		//
		// --------------------------------------------------------------------------
		private function mouseEventHandler(e : MouseEvent) : void
		{
			switch(e.type)
			{
				case MouseEvent.ROLL_OVER:
				{
					tweenHover(true);
					break;
				}
				case MouseEvent.ROLL_OUT:
				{
					tweenHover(false);
					break;
				}
			}
		}
	}
}


