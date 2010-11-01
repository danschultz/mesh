package operations
{
	import flash.events.Event;
	
	/**
	 * An event that is dispatched by an operation to indicate that its execution
	 * has finished, either successfully or unsuccessfully.
	 * 
	 * @author Dan Schultz
	 */
	public class FinishedOperationEvent extends OperationEvent
	{
		/**
		 * An event type for when an operation has finished executing.
		 */
		public static const FINISHED:String = "finished";
		
		/**
		 * Constructor.
		 * 
		 * @param successful Indicates whether the operation finished successfully.
		 */
		public function FinishedOperationEvent(successful:Boolean)
		{
			super(FINISHED);
			_successful = successful;
		}
		
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new FinishedOperationEvent(successful);
		}
		
		private var _successful:Boolean;
		/**
		 * <code>true</code> if the operation execution finished successfully.
		 */
		public function get successful():Boolean
		{
			return _successful;
		}
	}
}