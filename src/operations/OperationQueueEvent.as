package operations
{
	import flash.events.Event;
	
	/**
	 * An event that is dispatched by the <code>OperationQueue</code>.
	 * 
	 * @author Dan Schultz
	 */
	public class OperationQueueEvent extends Event
	{
		/**
		 * An event type that is dispatched when the queue has started.
		 */
		public static const STARTED:String = "started";
		
		/**
		 * An event type that is dispatched when there's any progress within the queue.
		 */
		public static const PROGRESS:String = "progress";
		
		/**
		 * An event type that is dispatched when the queue has been paused.
		 */
		public static const PAUSED:String = "paused";
		
		/**
		 * An event type that is dispatched when there are no elements left in the queue.
		 */
		public static const IDLE:String = "idle";
		
		/**
		 * Constructor.
		 * 
		 * @param type The event type.
		 */
		public function OperationQueueEvent(type:String)
		{
			super(type);
		}
		
		/**
		 * The queue that dispatched this event.
		 */
		public function get queue():OperationQueue
		{
			return OperationQueue( target );
		}
	}
}