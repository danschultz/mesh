package events
{
	import flash.events.Event;

	/**
	 * Generates an event handler function that will execute another function with 
	 * the given arguments. This is useful for easily executing simple functions
	 * on an event's action.
	 * 
	 * <listing version="3.0">
	 * var add:Function = function(num1:Number, num2:Number):void
	 * {
	 * 	trace(num1 + num2);
	 * };
	 * 
	 * var dispatcher:IEventDispatcher = new ClassThatDispatchesEvents();
	 * dispatcher.addEventListener(SomeEvent.EVENT, handle(add, 1, 2)); // will trace "3" when SomeEvent is dispatched.
	 * </listing>
	 * 
	 * @param func The function to execute.
	 * @param args The arguments to pass to the function.
	 * @return An event handler.
	 */
	public function handle(func:Function, ... args):Function
	{
		return function(event:Event):void
		{
			func.apply(null, args);
		};
	}
}