package mesh.core
{
	/**
	 * A delegate that provides data to a <code>BatchedList</code>. The batched list
	 * looks to its delegate to fetch elements that do not yet exist in the list. A
	 * base delegate class is provided to make implementing this interface simpler.
	 * 
	 * @see BatchedList
	 * @see BatchedListDelegate
	 * 
	 * @author Dan Schultz
	 */
	public interface IBatchedListDelegate
	{
		/**
		 * Called by the list when it needs to know the total number of elements that
		 * it contains. After the delegate has fetched the length, it must set the 
		 * length of the list by calling the <code>provideLength()</code> method.
		 * 
		 * @param list The list requesting its length.
		 * @se BatchedList#provideLength()
		 */
		function requestLength(list:BatchedList):void;
		
		/**
		 * Called by the list when it needs to fetch a batch of elements. After the 
		 * delegate has fetched the batch, it must call the <code>provideBatch()</code>
		 * method to insert the batch into the list.
		 * 
		 * @param list The list requesting the batch.
		 * @param index The index of the batch.
		 * @param batchSize The size of the batch to fetch.
		 * 
		 * @see BatchedList#provideBatch()
		 */
		function requestBatch(list:BatchedList, index:uint, batchSize:uint):void;
	}
}