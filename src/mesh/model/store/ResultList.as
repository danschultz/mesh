package mesh.model.store
{
	import flash.events.Event;
	
	import mesh.core.List;
	import mesh.model.Entity;
	
	import mx.collections.ArrayList;
	import mx.collections.ListCollectionView;
	import mx.collections.Sort;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	
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
		
		private var _keys:ListCollectionView;
		private var _entities:ArrayList;
		
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
			
			_keys = createKeyList();
			_keys.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleKeyListChange);
			handleKeysReset();
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
			_keys.addItem(key);
		}
		
		/**
		 * Invoke this method when the results for the list have been retrieved.
		 */
		public function complete():void
		{
			_isLoaded = true;
			dispatchEvent( new Event(Event.COMPLETE) );
		}
		
		private function createKeyList():ListCollectionView
		{
			var keys:ListCollectionView = new ListCollectionView(_store.data.keysForType(_query.entityType));
			keys.filterFunction = function(key:Object):Boolean
			{
				return _query.contains(_store.materialize(key));
			};
			keys.sort = new Sort();
			keys.sort.compareFunction = function(key1:Object, key2:Object, ...args):int
			{
				return _query.compare(_store.materialize(key1), _store.materialize(key2));
			};
			keys.refresh();
			return keys;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function getItemIndex(item:Object):int
		{
			item = item is Entity ? (item as Entity).storeKey : item;
			return super.getItemIndex(item);
		}
		
		private function handleKeyListChange(event:CollectionEvent):void
		{
			switch (event.kind) {
				case CollectionEventKind.ADD:
					handleKeysAdded(event.items);
					break;
				case CollectionEventKind.REMOVE:
					handleKeysRemoved(event.location, event.items.length);
					break;
				case CollectionEventKind.RESET:
					handleKeysReset();
					break;
			}
		}
		
		private function handleKeysAdded(keys:Array):void
		{
			for each (var key:Object in keys) {
				super.addItemAt(_store.materialize(key), length);
			}
		}
		
		private function handleKeysRemoved(index:int, length:int):void
		{
			for (var i:int = 0; i < length; i++) {
				super.removeItemAt(index);
			}
		}
		
		private function handleKeysReset():void
		{
			super.removeAll();
			handleKeysAdded(_keys.toArray());
		}
		
		/**
		 * @private
		 * 
		 * Don't allow removal of entities, since it would affect the store's behavior.
		 */
		override public function removeAll():void
		{
			
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