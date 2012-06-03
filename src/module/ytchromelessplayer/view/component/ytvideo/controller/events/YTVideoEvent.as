package module.ytchromelessplayer.view.component.ytvideo.controller.events
{
	import flash.events.Event;

	public class YTVideoEvent extends Event
	{
		public static const UPDATE_STATUS : String = "UPDATE_STATUS";
		public static const PLAYER_READY : String = "PLAYER_READY";
		private var _body : *;

		public function YTVideoEvent(type : String, body : * = null, bubbles : Boolean = false, cancelable : Boolean = false)
		{
			_body = body;
			super(type, bubbles, cancelable);
		}

		public function get body() : *
		{
			return _body;
		}

		override public function clone() : Event
		{
			return new YTVideoEvent(type, body);
		}
	}
}