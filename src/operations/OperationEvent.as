package operations
{
	import flash.events.Event;
	
	/**
	 * An <code>Operation</code> dispatches this event for simple statuses.
	 * 
	 * @see mesh.operations.Operation
	 * 
	 * @author Dan Schultz
	 */
	public class OperationEvent extends Event
	{
		/**
		 * The event type for when an operation is canceled.
		 */
		public static const CANCELED:String = "canceled";
		
		/**
		 * The event type for when an operation is executed.
		 */
		public static const EXECUTED:String = "executed";
		
		/**
		 * Constructor.
		 * 
		 * @param type The event type.
		 */
		public function OperationEvent(type:String)
		{
			super(type, bubbles, cancelable);
		}
		
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new OperationEvent(type);
		}
		
		/**
		 * The operation that dispatched this event.
		 */
		public function get operation():Operation
		{
			return target as Operation;
		}
	}
}