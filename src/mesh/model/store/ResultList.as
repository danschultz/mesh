package mesh.model.store
{
	import mesh.core.List;
	import mesh.model.Entity;
	
	import mx.collections.IList;
	import mx.collections.ListCollectionView;
	import mx.collections.Sort;
	
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
		private var _keyList:KeyList;
		
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
			
			_keyList = new KeyList(store);
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
			sortedList = new ListCollectionView(list);
			sortedList.filterFunction = _query.contains;
			sortedList.sort = new Sort();
			sortedList.sort.compareFunction = function(entity1:Entity, entity2:Entity, fields:Array = null):int
			{
				return _query.compare(entity1, entity2);
			};
			sortedList.refresh();
			return sortedList;
		}
		
		/**
		 * Invoke this method when the results for the list have been retrieved.
		 */
		public function complete():void
		{
			_isLoaded = true;
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

import mesh.model.Entity;
import mesh.model.store.Store;

import mx.collections.ArrayList;

/**
 * A list that holds the store keys for a result list. This list will turn store keys into
 * entities when requested.
 * 
 * @author Dan Schultz
 */
class KeyList extends ArrayList
{
	private var _store:Store;
	
	/**
	 * Constructor.
	 * 
	 * @param store The store to retrieve entities from.
	 */
	public function KeyList(store:Store)
	{
		super();
		_store = store;
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
}