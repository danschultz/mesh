package mesh.core.state
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	/**
	 * Dispatched when the machine enters this state.
	 */
	[Event(name="enter", type="mesh.core.state.StateEvent")]
	
	/**
	 * Dispatched when the machine exits this state.
	 */
	[Event(name="exit", type="mesh.core.state.StateEvent")]
	
	/**
	 * A state machine that supports states, actions, transitions and guards.
	 * 
	 * @author Dan Schultz
	 */
	public class StateMachine extends EventDispatcher
	{
		private var _states:Object = {};
		private var _actions:Object = {};
		
		/**
		 * Constructor.
		 */
		public function StateMachine()
		{
			super();
		}
		
		/**
		 * Adds an action to the machine. Actions have transitions attached to them that change the
		 * current state of the machine. To add transitions, call <code>Action.transition()</code>.
		 * To invoke an action and transition the state machine, either call the machine's 
		 * <code>invokeAction()</code> method, or call <code>Action.execute()</code>.
		 * 
		 * @param action The action's name.
		 * @return The action.
		 */
		public function createAction(action:String):Action
		{
			if (!_actions.hasOwnProperty(action)) {
				_actions[action] = new Action(this, action);
			}
			return _actions[action];
		}
		
		/**
		 * Adds a state to the machine. If the current state is <code>null</code>, then this will 
		 * become the current state.
		 * 
		 * @param state The state's name.
		 * @return A state.
		 */
		public function createState(state:String):State
		{
			if (!_states.hasOwnProperty(state)) {
				var s:State = new State(this, state);
				s.addEventListener(StateEvent.ENTER, handleStateEnter);
				s.addEventListener(StateEvent.EXIT, handleStateExit);
				
				_states[state] = s;
				
				if (_current == null) {
					transitionTo(s);
				}
			}
			return _states[state];
		}
		
		private function contains(state:Object):Boolean
		{
			return _states[state.toString()] != null;
		}
		
		private function handleStateExit(event:StateEvent):void
		{
			dispatchEvent(event.clone());
		}
		
		private function handleStateEnter(event:StateEvent):void
		{
			dispatchEvent(event.clone());
		}
		
		/**
		 * Listens for an event dispatched by the <code>host</code> that will trigger a function
		 * to be invoked. The block function must have the following signature:
		 * <code>function(machine:StateMachine):void</code>.
		 * 
		 * @param host The host to listen.
		 * @param event The event to listen for.
		 * @param block The function to execute when the event is dispatched.
		 */
		public function listen(host:IEventDispatcher, event:String):Action
		{
			var action:Action = createAction(event);
			host.addEventListener(event, function(event:Event):void
			{
				action.trigger();
			}, false, 0, true);
			return action;
		}
		
		/**
		 * Transitions the machine to the given state.
		 * 
		 * @param to The state to transition to.
		 */
		internal function transitionTo(to:State):void
		{
			if (current != null) {
				current.exit();
			}
			_current = to;
			to.enter();
		}
		
		/**
		 * Executes the transitions defined on the action.
		 * 
		 * @param action The name of the action to execute.
		 */
		public function triggerAction(action:String):void
		{
			createAction(action).trigger();
		}
		
		private function throwIfUndefinedState(state:Object):void
		{
			if (!contains(state)) {
				throw new ArgumentError("Undefined state '" + state + "'");
			}
		}
		
		private var _current:State;
		[Bindable(event="enter")]
		/**
		 * The current state.
		 */
		public function get current():State
		{
			return _current;
		}
	}
}