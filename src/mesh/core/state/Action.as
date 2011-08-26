package mesh.core.state
{
	/**
	 * An <code>Action</code> defines an event that can be triggered from a state machine.
	 * Actions contain transitions that change the current state of the state machine. These
	 * transitions are invoked whenever the action is triggered.
	 * 
	 * <p>
	 * To trigger an action, invoke the action's <code>trigger()</code> method, or call the
	 * state machine's <code>triggerAction()</code> method.
	 * </p>
	 * 
	 * @author Dan Schultz
	 */
	public class Action
	{
		private var _machine:StateMachine;
		private var _name:String;
		private var _transitions:Array = [];
		
		/**
		 * Constructor.
		 * 
		 * @param machine The machine that the action belongs to.
		 * @param name The name of this action.
		 */
		public function Action(machine:StateMachine, name:String)
		{
			_machine = machine;
			_name = name;
		}
		
		/**
		 * Triggers the action, and any transitions attached to it.
		 */
		public function trigger():void
		{
			for each (var transition:Transition in _transitions) {
				transition.trigger();
			}
		}
		
		/**
		 * Attaches a transition to this action.
		 * 
		 * @param to The transition's end state.
		 * @param from A list of states or a single start state of the transition.
		 * @param guard A guard function with the following signature: 
		 * 	<code>function():Boolean</code>.
		 * @return This action.
		 */
		public function transitionTo(to:Object, from:Object, guard:Function = null):Action
		{
			from = from is Array ? from : [from];
			for each (var fromState:Object in from) {
				_transitions.push( new Transition(_machine, _machine.createState(fromState.toString()), _machine.createState(to.toString()) , guard) );
			}
			return this;
		}
	}
}