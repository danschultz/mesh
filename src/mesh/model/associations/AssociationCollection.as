package mesh.model.associations
{
	import flash.utils.flash_proxy;
	import flash.utils.getDefinitionByName;
	
	import mesh.mesh_internal;
	import mesh.model.Record;
	import mesh.model.store.Commit;
	import mesh.model.store.ResultsList;
	import mesh.model.store.Store;
	import mesh.operations.Operation;
	
	import mx.collections.IList;
	import mx.collections.ListCollectionView;
	import mx.events.CollectionEvent;
	import mx.rpc.IResponder;
	
	use namespace mesh_internal;
	use namespace flash_proxy;
	
	public class AssociationCollection extends Association implements IList
	{
		private var _list:ListCollectionView;
		private var _results:ResultsList;
		
		/**
		 * @copy Association#Association()
		 */
		public function AssociationCollection(source:Record, property:String, options:Object = null)
		{
			super(source, property, options);
			
			_list = new ListCollectionView();
			_list.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleListCollectionChange);
		}
		
		/**
		 * Adds the given record to this association.
		 * 
		 * @param record The record to add.
		 */
		public function add(record:Record):void
		{
			associate(record);
		}
		
		/**
		 * @inheritDoc
		 */
		public function addItem(item:Object):void
		{
			add(Record( item ));
		}
		
		/**
		 * @inheritDoc
		 */
		public function addItemAt(item:Object, index:int):void
		{
			add(Record( item ));
		}
		
		/**
		 * @copy mesh.core.List#at()
		 */
		public function at(index:int):*
		{
			return getItemAt(index);
		}
		
		private function collectDirtyRecords():Array
		{
			var records:Array = [];
			for each (var record:Record in toArray()) {
				if (!record.state.isSynced) {
					records.push(record);
				}
			}
			return records;
		}
		
		/**
		 * Checks if a record belongs to this association.
		 * 
		 * @param record The record to check.
		 * @return <code>true</code> if the record was found.
		 */
		public function contains(record:Record):Boolean
		{
			return _list.contains(record);
		}
		
		/**
		 * @inheritDoc
		 */
		public function getItemAt(index:int, prefetch:int = 0):Object
		{
			return _list.getItemAt(index, prefetch);
		}
		
		/**
		 * @inheritDoc
		 */
		public function getItemIndex(item:Object):int
		{
			return _list.getItemIndex(item);
		}
		
		private function handleListCollectionChange(event:CollectionEvent):void
		{
			dispatchEvent(event);
		}
		
		/**
		 * @inheritDoc
		 */
		override mesh_internal function initialize():void
		{
			super.initialize();
			_list.list = _results = query(store);
		}
		
		/**
		 * @inheritDoc
		 */
		public function itemUpdated(item:Object, property:Object = null, oldValue:Object = null, newValue:Object = null):void
		{
			_list.itemUpdated(item, property, oldValue, newValue);
		}
		
		/**
		 * @copy mesh.model.store.ResultsList#load()
		 */
		public function load():*
		{
			if (_results != null) {
				_results.load();
			}
			return this;
		}
		
		public function persist(responder:IResponder = null):AssociationCollection
		{
			new Commit(store.dataSource, collectDirtyRecords()).persist();
			return this;
		}
		
		/**
		 * @copy mesh.model.store.ResultsList#refresh()
		 */
		public function refresh():*
		{
			if (_results != null) {
				_results.refresh();
			}
			return this;
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeAll():void
		{
			while (length > 0) {
				removeItemAt(0);
			}
		}
		
		/**
		 * Unassociates the record from this association.
		 * 
		 * @param record The record to remove.
		 */
		public function remove(record:Record):void
		{
			if (contains(record)) {
				unassociate(record);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeItemAt(index:int):Object
		{
			var record:Record = Record( getItemAt(index) );
			remove(record);
			return record;
		}
		
		/**
		 * @inheritDoc
		 */
		public function setItemAt(item:Object, index:int):Object
		{
			// Not supported.
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function toArray():Array
		{
			return _list.toArray();
		}
		
		/**
		 * @copy mesh.model.store.ResultsList#isLoaded
		 */
		public function get isLoaded():Boolean
		{
			return _results != null ? _results.isLoaded : false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get length():int
		{
			return _list.length;
		}
		
		/**
		 * @copy mesh.model.store.ResultsList#loadOperation
		 */
		public function get loadOperation():Operation
		{
			return _results != null ? _results.loadOperation : null;
		}
		
		private var _query:Function;
		/**
		 * A function that is called to query the data for this association. This function expects the 
		 * following signature: <code>function(store:Store):IList</code>.
		 */
		public function get query():Function
		{
			if (_query == null) {
				return function(store:Store):IList
				{
					var options:Object = {};
					options[inverse + "Id"] = owner.id;
					return store.query(recordType).where(options);
				};
			}
			return _query;
		}
		public function set query(value:Function):void
		{
			_query = value;
		}
		
		private function get recordType():Class
		{
			return Class( getDefinitionByName(options.recordType) );
		}
		
		// Proxy methods to support for each..in loops.
		
		/**
		 * @private
		 */
		override flash_proxy function nextName(index:int):String
		{
			return (index-1).toString();
		}
		
		private var _iteratingItems:Array;
		private var _len:int;
		/**
		 * @private
		 */
		override flash_proxy function nextNameIndex(index:int):int
		{
			if (index == 0) {
				_iteratingItems = toArray();
				_len = _iteratingItems.length;
			}
			return index < _len ? index+1 : 0;
		}
		
		/**
		 * @private
		 */
		override flash_proxy function nextValue(index:int):*
		{
			return _iteratingItems[index-1];
		}
	}
}
