package mesh.core.state
{
	import flash.events.EventDispatcher;

	/**
	 * Dispatched when the machine enters this state.
	 */
	[Event(name="enter", type="mesh.core.state.StateEvent")]
	
	/**
	 * Dispatched when the machine exits this state.
	 */
	[Event(name="exit", type="mesh.core.state.StateEvent")]
	
	/**
	 * An individual state within the state machine.
	 * 
	 * @author Dan Schultz
	 */
	public class State extends EventDispatcher
	{
		private var _machine:StateMachine;
		
		private var _onEnter:Function;
		private var _onExit:Function;
		
		/**
		 * Constructor.
		 * 
		 * @param machine The state machine the state belongs to.
		 * @param name The name for this state.
		 */
		public function State(machine:StateMachine, name:String)
		{
			super();
			_name = name;
			_machine = machine;
			
			addEventListener(StateEvent.ENTER, function(event:StateEvent):void
			{
				if (_onEnter != null) {
					_onEnter();
				}
			});
			addEventListener(StateEvent.EXIT, function(event:StateEvent):void
			{
				if (_onExit != null) {
					_onExit();
				}
			});
		}
		
		public function equals(state:Object):Boolean
		{
			return state is State && name == state.name;
		}
		
		/**
		 * Adds or replaces the callback function that is invoked when the state machine
		 * enters this state. The function should have the following signature: 
		 * <code>function():void</code>.
		 * 
		 * @param block A function.
		 * @return This instance.
		 */
		public function onEnter(block:Function):State
		{
			_onEnter = block;
			return this;
		}
		
		/**
		 * Called by the state machine when this state becomes the current state.
		 */
		internal function enter():void
		{
			dispatchEvent( new StateEvent(StateEvent.ENTER, this) );
		}
		
		/**
		 * Adds or replaces the callback function that is invoked when the state machine
		 * exits this state. The function should have the following signature: 
		 * <code>function():void</code>.
		 * 
		 * @param block A function.
		 * @return This instance.
		 */
		public function onExit(block:Function):State
		{
			_onExit = block;
			return this;
		}
		
		/**
		 * Called by the state machine when this state is transitioned to a new state.
		 */
		internal function exit():void
		{
			dispatchEvent( new StateEvent(StateEvent.EXIT, this) );
		}
		
		/**
		 * @private
		 */
		override public function toString():String
		{
			return _name;
		}
		
		private var _name:String;
		/**
		 * The state's name.
		 */
		public function get name():String
		{
			return _name;
		}
	}
}