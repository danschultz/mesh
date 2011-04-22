package mesh.operations
{
	import flash.events.ProgressEvent;

	/**
	 * An event that is dispatched by an operation to indicate its progress.
	 * 
	 * @author Dan Schultz
	 */
	public class ProgressOperationEvent extends OperationEvent
	{
		/**
		 * An event type for when an operation has progressed.
		 */
		public static const PROGRESS:String = "progress";
		
		/**
		 * @copy OperationEvent#OperationEvent()
		 */
		public function ProgressOperationEvent(type:String)
		{
			super(type);
		}
		
		/**
		 * @copy Operation#unitsComplete
		 */
		public function get unitsComplete():Number
		{
			return operation.progress.complete;
		}
		
		/**
		 * @copy Operation#unitsTotal
		 */
		public function get unitsTotal():Number
		{
			return operation.progress.total;
		}
	}
}