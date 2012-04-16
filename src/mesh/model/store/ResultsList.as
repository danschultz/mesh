package mesh.model.store
{
	import mesh.core.List;
	import mesh.mesh_internal;
	import mesh.model.Record;
	import mesh.operations.FinishedOperationEvent;
	import mesh.operations.Operation;
	
	import mx.collections.IList;
	import mx.collections.ListCollectionView;
	
	use namespace mesh_internal;
	
	public class ResultsList extends List
	{
		private var _resultsWrapper:ListCollectionView;
		
		public function ResultsList(results:IList, loadOperation:Operation)
		{
			super();
			
			_loadOperation = loadOperation;
			_loadOperation.addEventListener(FinishedOperationEvent.FINISHED, function(event:FinishedOperationEvent):void
			{
				_isLoaded = event.successful;
			});
			
			_resultsWrapper = new ListCollectionView(results);
			_resultsWrapper.filterFunction = filterRecord;
			_resultsWrapper.refresh();
			list = _resultsWrapper;
		}
		
		/**
		 * @private
		 */
		override public function addItemAt(item:Object, index:int):void
		{
			// Disabled so clients can't add records directly to the result.
		}
		
		private function filterRecord(record:Record):Boolean
		{
			return !(record.state.isDestroyed && record.state.isSynced);
		}
		
		/**
		 * @copy mesh.model.Record#load()
		 */
		public function load():*
		{
			if (!isLoaded) {
				refresh();
			}
			return this;
		}
		
		/**
		 * @copy mesh.model.Record#refresh()
		 */
		public function refresh():*
		{
			loadOperation.queue();
			loadOperation.execute();
			return this;
		}
		
		/**
		 * @private
		 */
		override public function removeItemAt(index:int):Object
		{
			// Disabled so clients can't remove records directly from the result.
			return null;
		}
		
		/**
		 * @private
		 */
		override public function setItemAt(item:Object, index:int):Object
		{
			// Disabled so clients can't replace records directly in the result.
			return null;
		}
		
		private var _isLoaded:Boolean;
		/**
		 * @copy mesh.model.Record#isLoaded
		 */
		public function get isLoaded():Boolean
		{
			return _isLoaded;
		}
		
		private var _loadOperation:Operation;
		/**
		 * @copy mesh.model.Record#loadOperation
		 */
		public function get loadOperation():Operation
		{
			return _loadOperation;
		}
	}
}