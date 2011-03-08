package operations
{
	import mesh.core.number.Fraction;

	/**
	 * A progress class that's specific for an <code>OperationQueue</code>.
	 * 
	 * @author Dan Schultz
	 */
	public class QueueProgress extends Progress
	{
		private var _queue:OperationQueue;
		
		/**
		 * Constructor.
		 * 
		 * @param queue The queue that owns this progress.
		 */
		public function QueueProgress(queue:OperationQueue)
		{
			_queue = queue;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get complete():Number
		{
			var temp:Number = 0;
			for each (var executing:Operation in _queue.executing) {
				temp += executing.progress.complete;
			}
			return super.complete + temp;
		}
	}
}