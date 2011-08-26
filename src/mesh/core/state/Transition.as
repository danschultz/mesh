package mesh.core.state
{
	import flash.events.EventDispatcher;
	
	/**
	 * Dispatched when the transition was triggered.
	 */
	[Event(name="transitioned", type="mesh.core.state.TransitionEvent")]
	
	/**
	 * A <code>Transition</code> defines a state machine's change from one state to another state. 
	 * The transition may be given an optional guard function that is evaluated when the transition 
	 * is triggered. If the guard returns <code>false</code> the transition fails. This guard 
	 * function must have the following signature: <code>function():Boolean</code>.
	 * 
	 * @author Dan Schultz
	 */
	public class Transition extends EventDispatcher
	{
		private var _machine:StateMachine;
		private var _guard:Function;
		private var _onTransition:Function;
		
		/**
		 * Constructor.
		 * 
		 * @param machine The machine the transition belongs to.
		 * @param from The transition's start state.
		 * @param to The transition's end state.
		 * @param guard The guard function that is invoked upon the triggering of the transition.
		 */
		public function Transition(machine:StateMachine, from:State, to:State, guard:Function = null)
		{
			super();
			_machine = machine;
			_from = from;
			_to = to;
			_guard = guard;
		}
		
		/**
		 * Adds or replaces the callback function that is on a transition. The function should have 
		 * the following signature: <code>function():void</code>.
		 * 
		 * @param block A function.
		 * @return This instance.
		 */
		public function onTransition(block:Function):Transition
		{
			_onTransition = block;
			return this;
		}
		
		/**
		 * Triggers the transition. If successful, the transition's state machine state will be put
		 * into the end state.
		 */
		public function trigger():void
		{
			if (_from.equals(_machine.current) && (_guard == null || _guard())) {
				_machine.transitionTo(_to);
				dispatchEvent( new TransitionEvent(TransitionEvent.TRANSITIONED, this) );
			}
		}
		
		private var _from:State;
		/**
		 * The transition's start state.
		 */
		public function get from():State
		{
			return _from;
		}

		private var _to:State;
		/**
		 * The transition's end state.
		 */
		public function get to():State
		{
			return _to;
		}
	}
}