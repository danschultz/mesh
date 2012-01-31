package mesh.model.store
{
	import collections.HashMap;
	
	import flash.events.IEventDispatcher;
	
	import mesh.core.List;
	
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.PropertyChangeEvent;

	/**
	 * A list belonging to the cache that contains data of the same type. This list will automatically
	 * index its data based on an ID field.
	 * 
	 * @author Dan Schultz
	 */
	public class Index extends List
	{
		private var _index:HashMap = new HashMap();
		private var _idField:String;
		
		/**
		 * Constructor.
		 */
		public function Index(idField:String = "id")
		{
			_idField = idField;
			addEventListener(CollectionEvent.COLLECTION_CHANGE, handleListChange);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function addItemAt(item:Object, index:int):void
		{
			if (contains(item)) {
				remove(item);
			}
			
			if (item is IEventDispatcher) {
				(item as IEventDispatcher).addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handlePropertyChange);
			}
			
			super.addItemAt(item, length);
		}
		
		/**
		 * Returns data that mapped to the given index.
		 * 
		 * @param id The index to grab.
		 * @return The mapped data.
		 */
		public function byId(id:Object):*
		{
			var element:Element = _index.grab(id);
			return element != null ? element.object : null;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function contains(item:Object):Boolean
		{
			return (hasID(item) && _index.containsKey(item.id)) || super.contains(item);
		}
		
		private function handleListChange(event:CollectionEvent):void
		{
			switch (event.kind) {
				case CollectionEventKind.ADD:
					itemsAdded(event.items, event.location);
					break;
				case CollectionEventKind.REMOVE:
					itemsRemoved(event.items);
					break;
			}
		}
		
		private function handlePropertyChange(event:PropertyChangeEvent):void
		{
			if (event.property == _idField) {
				var element:Element = _index.remove(event.oldValue);
				index(event.source, element != null ? element.index : getItemIndex(event.source));
			}
		}
		
		private function hasID(item:Object):Boolean
		{
			return item != null && (item[_idField] != null || item[_idField] != 0 || item[_idField] != "");
		}
		
		private function index(item:Object, i:int):void
		{
			if (hasID(item)) {
				_index.put(item[_idField], new Element(item, i));
			}
		}
		
		private function itemsAdded(items:Array, location:int):void
		{
			for (var i:int = 0; i < items.length; i++) {
				index(items[i], location+i);
			}
		}
		
		private function itemsRemoved(items:Array):void
		{
			for each (var item:Object in items) {
				unindex(item);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function remove(item:Object):void
		{
			var element:Element = _index.grab(item.id);
			if (element != null) {
				removeItemAt(element.index);
			} else {
				super.remove(item);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function removeItemAt(index:int):Object
		{
			var item:Object = super.removeItemAt(index);
			
			if (item is IEventDispatcher) {
				(item as IEventDispatcher).removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handlePropertyChange);
			}
			
			return item;
		}
		
		/**
		 * @private
		 */
		override public function setItemAt(item:Object, index:int):Object
		{
			// Disabled
			return null;
		}
		
		private function unindex(item:Object):void
		{
			if (hasID(item)) {
				_index.remove(item[_idField]);
			}
		}
	}
}

class Element
{
	public var object:Object;
	public var index:int;
	
	public function Element(object:Object, index:int)
	{
		this.object = object;
		this.index = index;
	}
}