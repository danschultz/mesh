package mesh.core.state
{
	import flash.events.Event;
	
	/**
	 * An event dispatched by a <code>State</code> when the state machine either enters or
	 * exits a state.
	 * 
	 * @author Dan Schultz
	 */
	public class StateEvent extends Event
	{
		/**
		 * Dispatched by a state when the machine enters this state.
		 */
		public static const ENTER:String = "enter";
		
		/**
		 * Dispatched by a state whent he machine exits this state.
		 */
		public static const EXIT:String = "exit";
		
		/**
		 * Constructor.
		 * 
		 * @param type The event type.
		 * @param state The event's state.
		 */
		public function StateEvent(type:String, state:State, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			_state = state;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function clone():Event
		{
			return new StateEvent(type, state, bubbles, cancelable);
		}
		
		private var _state:State;
		/**
		 * The state for this event.
		 */
		public function get state():State
		{
			return _state;
		}
	}
}