package mesh.model.store
{
	import mesh.core.List;
	import mesh.model.Entity;
	import mesh.model.load.LoadHelper;
	import mesh.model.source.SourceFault;
	
	import mx.collections.IList;
	import mx.collections.ListCollectionView;
	import mx.collections.Sort;
	
	/**
	 * Dispatched when the result list starts loading its content.
	 */
	[Event(name="loading", type="mesh.model.load.LoadEvent")]
	
	/**
	 * Dispatched when the result list has successfully loaded its content.
	 */
	[Event(name="success", type="mesh.model.load.LoadSuccessEvent")]
	
	/**
	 * Dispatched when the result list has failed to load its content.
	 */
	[Event(name="failed", type="mesh.model.load.LoadFailedEvent")]
	
	/**
	 * The <code>ResultList</code> is a list of entities after an execution of a query.
	 * 
	 * <p>
	 * <strong>Note:</strong> This list is immutable, and elements cannot be added or removed 
	 * from it. This is precautionary, since adding or removing elements from this list would
	 * affect the behavior of the store. This functionality will need to be revisited later.
	 * </p>
	 * 
	 * @author Dan Schultz
	 */
	public class ResultList extends List
	{
		private var _query:Query;
		private var _store:Store;
		private var _list:ListCollectionView;
		
		private var _helper:LoadHelper;
		
		/**
		 * Constructor.
		 * 
		 * @param query The query bound to this result.
		 * @param store The store which created this list. 
		 */
		public function ResultList(query:Query, store:Store)
		{
			super();
			
			_query = query;
			_store = store;
			
			_helper = new LoadHelper(this);
		}
		
		/**
		 * @private
		 * 
		 * Don't allow addition of entities, since it would affect the store's behavior.
		 */
		override public function addItemAt(item:Object, index:int):void
		{
			
		}
		
		private function createList(results:IList):void
		{
			if (_list == null) {
				_list = new ListCollectionView(results);
				_list.filterFunction = _query.contains;
				_list.sort = new Sort();
				_list.sort.compareFunction = function(entity1:Entity, entity2:Entity, fields:Array = null):int
				{
					return _query.compare(entity1, entity2);
				};
				_list.refresh();
				list = _list;
			}
		}
		
		/**
		 * Used internally by Mesh to indicate that the query for this result list failed while loading
		 * its data.
		 * 
		 * @param fault The reason of the failure.
		 */
		internal function failed(fault:SourceFault):void
		{
			_helper.failed(fault);
		}
		
		/**
		 * Used internally by Mesh to load the fetched data from a data source into the result list.
		 * 
		 * @param list The list of data to populate the result with.
		 */
		internal function loaded(results:IList):void
		{
			createList(results);
			_helper.loaded(results);
		}
		
		/**
		 * Refreshes the results of this list based on the list's query.
		 * 
		 * @return This list.
		 */
		public function refresh():ResultList
		{
			_helper.load();
			_store.dataSource.fetch(_store, _query);
			
			if (_query is LocalQuery) {
				createList(_store.index.findByType(_query.entityType));
			}
			
			return this;
		}
		
		/**
		 * @private
		 * 
		 * Don't allow removal of entities, since it would affect the store's behavior.
		 */
		override public function removeItemAt(index:int):Object
		{
			return null;
		}
		
		/**
		 * Indicates if the data for this result has been loaded.
		 */
		public function get isLoaded():Boolean
		{
			return _helper.isLoaded;
		}
		
		/**
		 * Indicates if the data for this result is currently loading.
		 */
		public function get isRefreshing():Boolean
		{
			return _helper.isLoading;
		}
	}
}