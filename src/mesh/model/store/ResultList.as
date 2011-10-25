package mesh.model.store
{
	import flash.events.Event;
	
	import mesh.core.List;
	import mesh.model.Entity;
	
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.collections.ListCollectionView;
	import mx.collections.Sort;
	
	/**
	 * Dispatched when the results for the list are complete.
	 */
	[Event(name="complete", type="flash.events.Event")]
	
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
		private var _keyList:ArrayList;
		
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
			
			_keyList = new ArrayList();
			list = createList(_keyList);
		}
		
		/**
		 * @private
		 * 
		 * Don't allow addition of entities, since it would affect the store's behavior.
		 */
		override public function addItemAt(item:Object, index:int):void
		{
			
		}
		
		/**
		 * Adds a store key as a result for this list.
		 * 
		 * @param key The key to add.
		 */
		public function addKey(key:Object):void
		{
			_keyList.addItem(key);
		}
		
		private function createList(list:IList):IList
		{
			var sortedList:ListCollectionView = new ListCollectionView(list);
			sortedList.filterFunction = function(key:Object):Boolean
			{
				return _query.contains(_store.materialize(key));
			};
			sortedList.sort = new Sort();
			sortedList.sort.compareFunction = function(key1:Object, key2:Object, ...args):int
			{
				return _query.compare(_store.materialize(key1), _store.materialize(key2));
			};
			sortedList.refresh();
			return sortedList;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function getItemAt(index:int, prefetch:int=0):Object
		{
			return _store.materialize(super.getItemAt(index, prefetch));
		}
		
		/**
		 * @inheritDoc
		 */
		override public function getItemIndex(item:Object):int
		{
			item = item is Entity ? (item as Entity).storeKey : item;
			return super.getItemIndex(item);
		}
		
		/**
		 * Invoke this method when the results for the list have been retrieved.
		 */
		public function complete():void
		{
			_isLoaded = true;
			dispatchEvent( new Event(Event.COMPLETE) );
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
		
		private var _isLoaded:Boolean;
		/**
		 * <code>true</code> if results have been loaded into this list.
		 */
		public function get isLoaded():Boolean
		{
			return _isLoaded;
		}
	}
}