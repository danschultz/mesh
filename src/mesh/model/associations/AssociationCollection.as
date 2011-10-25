package mesh.model.associations
{
	import flash.events.Event;
	
	import mesh.model.Entity;
	import mesh.model.store.Query;
	import mesh.model.store.ResultList;
	
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.PropertyChangeEvent;
	
	public class AssociationCollection extends Association implements IList
	{
		private var _list:SynchronizedList;
		private var _snapshot:Array = [];
		private var _results:ResultList;
		
		/**
		 * @copy AssociationProxy#AssociationProxy()
		 */
		public function AssociationCollection(source:Entity, property:String, options:Object = null)
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
					handleEntitiesAdded(event.items);
					break;
				case CollectionEventKind.REMOVE:
					handleEntitiesRemoved(event.items);
					break;
				case CollectionEventKind.REPLACE:
					handleEntitiesReplaced(event.items);
					break;
				case CollectionEventKind.RESET:
					handleEntitiesReset();
					break;
			}
			
			if (event.kind != CollectionEventKind.UPDATE) {
				_snapshot = _list.toArray();
			}
			
			dispatchEvent(event);
		}
		
		private function handleEntitiesAdded(items:Array):void
		{
			for each (var entity:Entity in items) {
				associate(entity);
			}
		}
		
		private function handleEntitiesRemoved(items:Array):void
		{
			for each (var entity:Entity in items) {
				unassociate(entity);
			}
		}
		
		private function handleEntitiesReplaced(items:Array):void
		{
			for each (var change:PropertyChangeEvent in items) {
				handleEntitiesRemoved([change.oldValue]);
				handleEntitiesAdded([change.newValue]);
			}
		}
		
		private function handleEntitiesReset():void
		{
			for each (var oldEntity:Entity in _snapshot) {
				handleEntitiesRemoved([oldEntity]);
			}
			
			for each (var newEntity:Entity in _list.toArray()) {
				handleEntitiesAdded([newEntity]);
			}
		}
		
		private function handleResultsComplete(event:Event):void
		{
			loaded();
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
			super.performLoad();
			
			if (_results != null) {
				_results.removeEventListener(Event.COMPLETE, handleResultsComplete);
			}
			
			_results = owner.store.find(query);
			_results.addEventListener(Event.COMPLETE, handleResultsComplete);
			_list.list = _results;
			
			if (_results.isLoaded) {
				loaded();
			}
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
		
		/**
		 * The query to load the data for this association.
		 */
		protected function get query():Query
		{
			return options.query is Function ? options.query() : options.query;
		}
	}
}

import mesh.model.Entity;
import mesh.model.store.ResultList;

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
		for each (var result:Entity in items) {
			addItem(result);
		}
	}
	
	private function handleListItemsRemoved(items:Array):void
	{
		for each (var result:Entity in items) {
			removeItem(result);
		}
	}
	
	private function handleListItemsReplaced(items:Array):void
	{
		for each (var change:PropertyChangeEvent in items) {
			handleListItemsAdded([change.oldValue]);
			handleListItemsRemoved([change.newValue]);
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