package mesh.core
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	
	/**
	 * Dispatched when the IList has been updated in some way.
	 * 
	 * @eventType mx.events.CollectionEvent.COLLECTION_CHANGE
	 */
	[Event(name="collectionChange", type="mx.events.CollectionEvent")]
	
	/**
	 * A list that wraps a Flex <code>ArrayList</code> and adds additional 
	 * utility methods for working with lists. This list supports 
	 * <code>for each..in</code> iteration.
	 * 
	 * @author Dan Schultz
	 */
	public class List extends Proxy implements IList, IEventDispatcher
	{
		private var _dispatcher:EventDispatcher;
		private var _list:IList;
		
		/**
		 * @copy mx.collections.ArrayList#ArrayList()
		 */
		public function List(source:Array = null)
		{
			super();
			_dispatcher = new EventDispatcher(this);
			list = new ArrayList(source);
		}
		
		/**
		 * @copy #addItem()
		 */
		public function add(item:Object):void
		{
			addItem(item);
		}
		
		/**
		 * Adds all the elements from an <code>Array</code> or <code>IList</code> to the
		 * end of this list.
		 * 
		 * @param arrayOrList The elements to add.
		 */
		public function addAll(arrayOrList:Object):void
		{
			addAllAt(arrayOrList, length); 
		}
		
		/**
		 * Adds all the elements from an <code>Array</code> or <code>IList</code> to this
		 * list at the given index.
		 * 
		 * @param arrayOrList The elements to add.
		 * @param index The index to insert the first element at.
		 */
		public function addAllAt(arrayOrList:Object, index:int):void
		{
			if (arrayOrList is IList) {
				arrayOrList = (arrayOrList as IList).toArray();
			}
			
			if (!(arrayOrList is Array)) {
				throw new ArgumentError("Expected an Array or IList.");
			}
			
			var len:int = arrayOrList.length;
			for (var i:int = 0; i < len; i++) {
				addItemAt(arrayOrList[i], index+i);
			}
		}
		
		/**
		 * @copy #addItemAt()
		 */
		public function addAt(item:Object, index:int):void
		{
			addItemAt(item, index);
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
		 * Checks if the item belongs to this list.
		 * 
		 * @param item The item to check.
		 * @return <code>true</code> if the item was found.
		 */
		public function contains(item:Object):Boolean
		{
			return getItemIndex(item) != -1;
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
		public function itemUpdated(item:Object, property:Object = null, oldValue:Object = null, newValue:Object = null):void
		{
			_list.itemUpdated(item, property, oldValue, newValue);
		}
		
		/**
		 * Returns an immutable list where each item is a remapping of an item in this list. 
		 * This method accepts either a property to map to, or a block function that returns
		 * the mapped value. The returned list will receive updates when items are either
		 * added or removed from this list.
		 * 
		 * @param propertyOrBlock The property or function to map.
		 * @return A new list.
		 * 
		 */
		public function map(propertyOrBlock:Object):IList
		{
			return new MappedList(propertyOrBlock);
		}
		
		/**
		 * Removes an item from the list if it exists.
		 * 
		 * @param item The item to remove.
		 */
		public function remove(item:Object):void
		{
			var index:int = getItemIndex(item);
			if (index != -1) {
				removeItemAt(index);
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
		 * Removes each element from the <code>Array</code> or <code>IList</code> from
		 * this list.
		 * 
		 * @param arrayOrList The elements to remove.
		 */
		public function removeEach(arrayOrList:Object):void
		{
			if (arrayOrList is IList) {
				arrayOrList = (arrayOrList as IList).toArray();
			}
			
			for each (var item:Object in arrayOrList) {
				remove(item);
			}
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
		 * Allows sub-classes to supply their own list implementation.
		 * 
		 * @param value The list to wrap.
		 */
		protected function set list(value:IList):void
		{
			if (_list != null) {
				_list.removeEventListener(CollectionEvent.COLLECTION_CHANGE, handleListCollectionChange);
			}
			
			_list = value != null ? value : new ArrayList();
			_list.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleListCollectionChange);
			dispatchEvent( new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.RESET) );
		}
		
		/**
		 * @inheritDoc
		 */
		public function get length():int
		{
			return _list.length;
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
		
		// Methods for IEventDispatcher
		
		/**
		 * @inheritDoc
		 */
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			_dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		/**
		 * @inheritDoc
		 */
		public function dispatchEvent(event:Event):Boolean
		{
			return _dispatcher.dispatchEvent(event);
		}
		
		/**
		 * @inheritDoc
		 */
		public function hasEventListener(type:String):Boolean
		{
			return _dispatcher.hasEventListener(type);
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			_dispatcher.removeEventListener(type, listener, useCapture);
		}
		
		/**
		 * @inheritDoc
		 */
		public function willTrigger(type:String):Boolean
		{
			return _dispatcher.willTrigger(type);
		}
	}
}

import mesh.core.List;

import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;

class MappedList extends List
{
	private var _block:Function;
	
	public function MappedList(propertyOrBlock:Object)
	{
		super();
		
		if (propertyOrBlock is String) {
			_block = function(item:Object):Object
			{
				return item[propertyOrBlock];
			};
		}
		
		addEventListener(CollectionEvent.COLLECTION_CHANGE, handleCollectionChange);
	}
	
	override public function addItemAt(item:Object, index:int):void
	{
		// Do nothing. The list is immutable.
	}
	
	override public function getItemAt(index:int, prefetch:int=0):Object
	{
		return mappedValue(super.getItemAt(index, prefetch));
	}
	
	private function handleCollectionChange(event:CollectionEvent):void
	{
		switch (event.kind) {
			case CollectionEventKind.ADD:
			case CollectionEventKind.REMOVE:
				replaceEventValues(event);
				break;
		}
	}
	
	private function replaceEventValues(event:CollectionEvent):void
	{
		event.items.map(function(item:Object, index:int, array:Array):Object
		{
			return mappedValue(item);
		});
	}
	
	private function mappedValue(obj:Object):Object
	{
		return _block(obj);
	}
	
	override public function removeAll():void
	{
		// Do nothing. The list is immutable.
	}
	
	override public function removeItemAt(index:int):Object
	{
		// Do nothing. The list is immutable.
		return null;
	}
}