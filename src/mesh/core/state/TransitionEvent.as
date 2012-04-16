package mesh.core.state
{
	import flash.events.Event;
	
	/**
	 * An event that is dispatched from a transition.
	 * 
	 * @author Dan Schultz
	 */
	public class TransitionEvent extends Event
	{
		/**
		 * Dispatched by a transition when it has been triggered.
		 */
		public static const TRANSITIONED:String = "transitioned";
		
		/**
		 * Constructor.
		 * 
		 * @param type The event type.
		 * @param transition The transition that triggered the event.
		 */
		public function TransitionEvent(type:String, transition:Transition, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_transition = transition;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function clone():Event
		{
			return new TransitionEvent(type, transition, bubbles, cancelable);
		}
		
		private var _transition:Transition;
		/**
		 * The transition that triggered the event.
		 */
		public function get transition():Transition
		{
			return _transition;
		}
	}
}