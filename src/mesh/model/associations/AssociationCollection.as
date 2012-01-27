package mesh.model.associations
{
	import flash.events.Event;
	
	import mesh.model.Record;
	
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.PropertyChangeEvent;
	
	public class AssociationCollection extends Association implements IList
	{
		private var _list:SynchronizedList;
		private var _snapshot:Array = [];
		
		/**
		 * @copy AssociationProxy#AssociationProxy()
		 */
		public function AssociationCollection(source:Record, property:String, options:Object = null)
		{
			super(source, property, options);
			
			_list = new SynchronizedList();
			_list.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleListCollectionChange);
		}
		
		/**
		 * @inheritDoc
		 */
		public function addItem(item:Object):void
		{
			_list.addItem(item);
		}
		
		/**
		 * @inheritDoc
		 */
		public function addItemAt(item:Object, index:int):void
		{
			_list.addItemAt(item, index);
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
			switch (event.kind) {
				case CollectionEventKind.ADD:
					handleRecordsAdded(event.items);
					break;
				case CollectionEventKind.REMOVE:
					handleRecordsRemoved(event.items);
					break;
				case CollectionEventKind.REPLACE:
					handleRecordsReplaced(event.items);
					break;
				case CollectionEventKind.RESET:
					handleRecordsReset();
					break;
			}
			
			if (event.kind != CollectionEventKind.UPDATE) {
				_snapshot = _list.toArray();
			}
			
			dispatchEvent(event);
		}
		
		private function handleRecordsAdded(items:Array):void
		{
			for each (var record:Record in items) {
				associate(record);
			}
		}
		
		private function handleRecordsRemoved(items:Array):void
		{
			for each (var record:Record in items) {
				unassociate(record);
			}
		}
		
		private function handleRecordsReplaced(items:Array):void
		{
			for each (var change:PropertyChangeEvent in items) {
				handleRecordsRemoved([change.oldValue]);
				handleRecordsAdded([change.newValue]);
			}
		}
		
		private function handleRecordsReset():void
		{
			for each (var oldRecord:Record in _snapshot) {
				handleRecordsRemoved([oldRecord]);
			}
			
			for each (var newRecord:Record in _list.toArray()) {
				handleRecordsAdded([newRecord]);
			}
		}
		
		private function handleResultsComplete(event:Event):void
		{
			loaded();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function initialize():void
		{
			super.initialize();
		}
		
		/**
		 * @inheritDoc
		 */
		public function itemUpdated(item:Object, property:Object = null, oldValue:Object = null, newValue:Object = null):void
		{
			_list.itemUpdated(item, property, oldValue, newValue);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function performLoad():void
		{
			
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeAll():void
		{
			_list.removeAll();
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeItemAt(index:int):Object
		{
			return _list.removeItemAt(index);
		}
		
		/**
		 * @inheritDoc
		 */
		public function setItemAt(item:Object, index:int):Object
		{
			return _list.setItemAt(item, index);
		}
		
		/**
		 * @inheritDoc
		 */
		public function toArray():Array
		{
			return _list.toArray();
		}
		
		/**
		 * @inheritDoc
		 */
		public function get length():int
		{
			return _list.length;
		}
	}
}

import mesh.model.Record;

import mx.collections.ArrayList;
import mx.collections.IList;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.PropertyChangeEvent;

class SynchronizedList extends ArrayList
{
	private var _copy:Array;
	
	public function SynchronizedList()
	{
		super();
	}
	
	private function handleListCollectionChange(event:CollectionEvent):void
	{
		switch (event.kind) {
			case CollectionEventKind.ADD:
				handleListItemsAdded(event.items);
				break;
			case CollectionEventKind.REMOVE:
				handleListItemsRemoved(event.items);
				break;
			case CollectionEventKind.REPLACE:
				handleListItemsReplaced(event.items);
				break;
			case CollectionEventKind.RESET:
				handleListReset();
				break;
				
		}
		
		if (event.kind != CollectionEventKind.UPDATE) {
			_copy = list.toArray();
		}
	}
	
	private function handleListItemsAdded(items:Array):void
	{
		for each (var result:Record in items) {
			addItem(result);
		}
	}
	
	private function handleListItemsRemoved(items:Array):void
	{
		for each (var result:Record in items) {
			removeItem(result);
		}
	}
	
	private function handleListItemsReplaced(items:Array):void
	{
		for each (var change:PropertyChangeEvent in items) {
			handleListItemsRemoved([change.oldValue]);
			handleListItemsAdded([change.newValue]);
		}
	}
	
	private function handleListReset():void
	{
		handleListItemsRemoved(_copy);
		handleListItemsAdded(list.toArray());
	}
	
	private var _list:IList;
	public function get list():IList
	{
		return _list;
	}
	public function set list(value:IList):void
	{
		if (_list != value) {
			if (_list != null) _list.removeEventListener(CollectionEvent.COLLECTION_CHANGE, handleListCollectionChange);
			_list = value;
			if (_list != null) _list.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleListCollectionChange);
			handleListReset();
		}
	}
}