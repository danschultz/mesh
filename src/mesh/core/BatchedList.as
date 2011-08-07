package mesh.core
{
	/**
	 * A type of <code>List</code> that does not have all of its elements
	 * when its first created, but incrementally loads its elements as they're 
	 * requested.
	 * 
	 * @author Dan Schultz
	 */
	public class BatchedList extends List
	{
		private var _batches:Array = [];
		private var _delegate:IBatchedListDelegate;
		
		/**
		 * Constructor.
		 * 
		 * @param delegate The object responsible for fetching batches.
		 * @param batchSize The size of each batch.
		 */
		public function BatchedList(delegate:IBatchedListDelegate, batchSize:uint)
		{
			super();
			_delegate = delegate;
			_batchSize = batchSize;
		}
		
		private function batchIndexForListIndex(index:int):int
		{
			return Math.floor(index/batchSize);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function getItemAt(index:int, prefetch:int=0):Object
		{
			// The length hasn't been populated yet, so fetch the list length.
			if (isNaN(_providedLength)) {
				_delegate.requestLength(this);
				return undefined;
			}
			
			// The index is in bounds, so try to return the item if it's loaded,
			// or request the batch that would contain the item.
			if (index >= 0 && index < length) {
				var batchIndex:int = batchIndexForListIndex(index);
				if (_batches[batchIndex] != null) {
					return super.getItemAt(index);
				} else {
					_delegate.requestBatch(this, batchIndex, batchSize);
					return undefined;
				}
			}
			
			throw new RangeError(index.toString() + " is out of range.");
		}
		
		/**
		 * Called by the delegate to insert the elements from a fetch.
		 * 
		 * @param arrayOrList The elements of the batch.
		 * @param index The index to insert the elements at.
		 */
		public function provideBatch(arrayOrList:Object, index:int):void
		{
			_batches[index] = arrayOrList;
			addAllAt(arrayOrList, index > length ? length : index);
		}
		
		/**
		 * Delegates call this method to provide the total number of elements
		 * in the list.
		 * 
		 * @param length The number of elements in the list.
		 */
		public function provideLength(length:Number):void
		{
			_providedLength = length;
		}
		
		/**
		 * Resets the elements in this list and forces the elements to be reloaded.
		 */
		public function reset():void
		{
			removeAll();
			_batches = [];
			_providedLength = NaN;
		}
		
		private var _batchSize:uint;
		/**
		 * The size of each batch in a request.
		 */
		public function get batchSize():uint
		{
			return _batchSize;
		}
		
		private var _providedLength:Number;
		/**
		 * @inheritDoc
		 */
		override public function get length():int
		{
			return isNaN(_providedLength) ? _delegate.requestLength(this) : _providedLength;
		}
	}
}