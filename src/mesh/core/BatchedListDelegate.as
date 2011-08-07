package mesh.core
{
	/**
	 * A base delegate class to make implementation simpler.
	 * 
	 * @see IBatchedListDelegate
	 * 
	 * @author Dan Schultz
	 */
	public class BatchedListDelegate implements IBatchedListDelegate
	{
		/**
		 * Constructor.
		 */
		public function BatchedListDelegate()
		{
			
		}
		
		/**
		 * @inheritDoc
		 */
		public function requestLength(list:BatchedList):void
		{
			
		}
		
		/**
		 * @inheritDoc
		 */
		public function requestBatch(list:BatchedList, index:uint, batchSize:uint):void
		{
		}
	}
}