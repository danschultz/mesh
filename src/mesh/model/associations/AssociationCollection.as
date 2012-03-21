package mesh.model.associations
{
	import flash.utils.flash_proxy;
	import flash.utils.getDefinitionByName;
	
	import mesh.core.Set;
	import mesh.mesh_internal;
	import mesh.model.Record;
	import mesh.model.store.Commit;
	import mesh.model.store.ICommitResponder;
	import mesh.model.store.ResultsList;
	import mesh.model.store.Store;
	import mesh.operations.Operation;
	
	import mx.collections.IList;
	import mx.collections.ListCollectionView;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	
	use namespace mesh_internal;
	use namespace flash_proxy;
	
	public class AssociationCollection extends Association implements IList
	{
		private var _resultsList:ListCollectionView;
		private var _results:ResultsList;
		
		private var _records:MergedSet;
		private var _added:Set = new Set();
		private var _removed:Set = new Set();
		
		/**
		 * @copy Association#Association()
		 */
		public function AssociationCollection(source:Record, property:String, options:Object = null)
		{
			super(source, property, options);
			
			_resultsList = new ListCollectionView();
			_resultsList.filterFunction = filterRecord;
			_resultsList.refresh();
			
			_records = new MergedSet(_resultsList, _added);
			_records.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleListCollectionChange);
			
			_removed.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleRemovedSetChange);
		}
		
		private function handleRemovedSetChange(event:CollectionEvent):void
		{
			if (event.kind != CollectionEventKind.UPDATE) {
				_resultsList.refresh();
			}
		}
		
		/**
		 * Adds the given record to this association.
		 * 
		 * @param record The record to add.
		 */
		public function add(record:Record):void
		{
			_added.add(record);
			_removed.remove(record);
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
			return _records.contains(record);
		}
		
		private function filterRecord(record:Record):Boolean
		{
			return !_removed.contains(record);
		}
		
		/**
		 * @inheritDoc
		 */
		public function getItemAt(index:int, prefetch:int = 0):Object
		{
			return _records.getItemAt(index, prefetch);
		}
		
		/**
		 * @inheritDoc
		 */
		public function getItemIndex(item:Object):int
		{
			return _records.getItemIndex(item);
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
			
			var loadOperation:AssociationLoadOperation = new AssociationLoadOperation(store, owner, recordType);
			_resultsList.list = _results = new ResultsList(loadOperation.results, loadOperation);
		}
		
		/**
		 * @inheritDoc
		 */
		public function itemUpdated(item:Object, property:Object = null, oldValue:Object = null, newValue:Object = null):void
		{
			_records.itemUpdated(item, property, oldValue, newValue);
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
		
		public function persist(responder:ICommitResponder = null):AssociationCollection
		{
			var commit:Commit = new Commit(store.dataSource, collectDirtyRecords());
			if (responder != null) {
				commit.addResponder(responder);
			}
			commit.persist();
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
				_removed.add(record);
				_added.remove(record);
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
			return _records.toArray();
		}
		
		/**
		 * The set of records that have been removed from the association.
		 */
		public function get added():Array
		{
			return _added.toArray();
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
			return _records.length;
		}
		
		/**
		 * @copy mesh.model.store.ResultsList#loadOperation
		 */
		public function get loadOperation():Operation
		{
			return _results != null ? _results.loadOperation : null;
		}
		
		private function get recordType():Class
		{
			try {
				return Class( getDefinitionByName(options.recordType) );
			} catch (e:ReferenceError) {
				throw new ReferenceError("Record type '" + options.recordType + "' not found.");
			}
			return null;
		}
		
		/**
		 * The set of records that have been removed from the association.
		 */
		public function get removed():Array
		{
			return _removed.toArray();
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

import flash.utils.Dictionary;

import mesh.core.List;
import mesh.core.Set;
import mesh.mesh_internal;
import mesh.model.Record;
import mesh.model.associations.AssociationCollection;
import mesh.model.source.DataSourceRetrievalOperation;
import mesh.model.store.Data;
import mesh.model.store.RecordCache;
import mesh.model.store.Store;

import mx.collections.IList;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.PropertyChangeEvent;

use namespace mesh_internal;

class MergedSet extends Set
{
	private var _lists:Dictionary = new Dictionary();
	
	public function MergedSet(...lists):void
	{
		for each (var list:IList in lists) {
			addList(list);
		}
	}
	
	private function addList(list:IList):void
	{
		addAll(list);
		_lists[list] = list.toArray();
		list.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleListChange);
	}
	
	private function handleListChange(event:CollectionEvent):void
	{
		switch (event.kind) {
			case CollectionEventKind.ADD:
				handleListAdd(IList( event.target ), event.items, event.location);
				break;
			case CollectionEventKind.REMOVE:
				handleListRemove(IList( event.target ), event.items, event.location);
				break;
			case CollectionEventKind.REFRESH:
				handleListRefresh(IList( event.target ));
				break;
			case CollectionEventKind.RESET:
				handleListRefresh(IList( event.target ));
				break;
			case CollectionEventKind.REPLACE:
				handleListReplace(IList( event.target ), event.items);
				break;
		}
	}
	
	private function handleListAdd(list:IList, items:Array, location:int):void
	{
		for each (var item:Object in items) {
			addItem(item);
		}
		_lists[list].splice.apply(null, [location, 0].concat(items));
	}
	
	private function handleListRemove(list:IList, items:Array, location:int):void
	{
		for each (var item:Object in items) {
			remove(item);
		}
		_lists[list].splice.apply(null, [location, items.length]);
	}
	
	private function handleListRefresh(list:IList):void
	{
		removeEach(_lists[list]);
		addAll(list);
		_lists[list] = list.toArray();
	}
	
	private function handleListReplace(list:IList, changeEvents:Array):void
	{
		for each (var event:PropertyChangeEvent in changeEvents) {
			remove(event.oldValue);
			add(event.newValue);
		}
		_lists[list] = list.toArray();
	}
}

class AssociationLoadOperation extends DataSourceRetrievalOperation
{
	private var _store:Store;
	private var _records:RecordCache;
	
	public function AssociationLoadOperation(store:Store, owner:Record, recordType:Class)
	{
		_store = store;
		_records = store.records;
		super(_records, _store.dataSource.belongingTo, [owner, recordType]);
	}
	
	override public function loaded(data:Data):void
	{
		super.loaded(data);
		_results.addItem(_records.findIndex(data.type).byId(data.id));
	}
	
	private var _results:List = new List();
	public function get results():IList
	{
		return _results;
	}
}
