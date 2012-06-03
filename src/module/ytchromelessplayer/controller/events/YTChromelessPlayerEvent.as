package module.ytchromelessplayer.controller.events
{
	import flash.events.Event;

	public class YTChromelessPlayerEvent extends Event
	{
		public static const UPDATE_STATUS : String = "UPDATE_STATUS";
		public static const ADD_LISTENER_MOUSE_HOVER : String = "ADD_LISTENER_MOUSE_HOVER";
		private var _body : *;

		public function YTChromelessPlayerEvent(type : String, body : * = null, bubbles : Boolean = false, cancelable : Boolean = false)
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
			return new YTChromelessPlayerEvent(type, body);
		}
	}
}