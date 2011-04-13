package mesh.services
{
	import flash.utils.flash_proxy;
	
	import mesh.operations.Operation;
	
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.events.CollectionEvent;

	public class ListQueryRequest extends QueryRequest implements IList
	{
		private var _list:ArrayList;
		
		public function ListQueryRequest(operation:Operation)
		{
			super(operation);
			
			_list = new ArrayList();
			_list.addEventListener(CollectionEvent.COLLECTION_CHANGE, function(event:CollectionEvent):void
			{
				dispatchEvent(event);
			});
		}
		
		/**
		 * @inheritDoc
		 */
		public function addItem(item:Object):void
		{
			addItemAt(item, length);
		}
		
		/**
		 * @inheritDoc
		 */
		public function addItemAt(item:Object, index:int):void
		{
			flash_proxy::object.addItemAt(item, index);
		}
		
		/**
		 * Checks if the association has the given entity. This method will only check for entities
		 * that have already been loaded.
		 * 
		 * @param item The item to check.
		 * @return <code>true</code> if the item was found.
		 */
		public function contains(item:Object):Boolean
		{
			return getItemIndex(item) >= 0;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getItemAt(index:int, prefetch:int = 0):Object
		{
			return flash_proxy::object.getItemAt(index, prefetch);
		}
		
		/**
		 * @inheritDoc
		 */
		public function getItemIndex(item:Object):int
		{
			return flash_proxy::Object.getItemIndex(item);
		}
		
		/**
		 * @inheritDoc
		 */
		public function itemUpdated(item:Object, property:Object = null, oldValue:Object = null, newValue:Object = null):void
		{
			flash_proxy::object.itemUpdated(item, property, oldValue, newValue);
		}
		
		/**
		 *  @inheritDoc
		 */
		override flash_proxy function nextName(index:int):String
		{
			return (index-1).toString();
		}
		
		private var _iteratingItems:Array;
		private var _len:int;
		/**
		 * @inheritDoc
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
		 * @inheritDoc
		 */
		override flash_proxy function nextValue(index:int):*
		{
			return _iteratingItems[index-1];
		}
		
		/**
		 * @copy #removeItem()
		 */
		public function remove(item:Object):void
		{
			removeItem(item);
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeAll():void
		{
			flash_proxy::object.removeAll();
		}
		
		/**
		 * Removes the given entity from this association. This method will only remove entities
		 * that have been loaded into the association.
		 * 
		 * @param item The entity to remove.
		 */
		public function removeItem(item:Object):void
		{
			var index:int = getItemIndex(item);
			if (index >= 0) {
				removeItemAt(index);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeItemAt(index:int):Object
		{
			return flash_proxy::object.removeItemAt(index);
		}
		
		/**
		 * @inheritDoc
		 */
		public function setItemAt(item:Object, index:int):Object
		{
			return flash_proxy::object.setItemAt(item, index);
		}
		
		/**
		 * @inheritDoc
		 */
		public function toArray():Array
		{
			return flash_proxy::object.toArray();
		}
		
		/**
		 * @inheritDoc
		 */
		public function get length():int
		{
			return flash_proxy::object.length;
		}
		
		/**
		 * @inheritDoc
		 */
		override flash_proxy function get object():Object
		{
			return super.flash_proxy::object;
		}
		override flash_proxy function set object(value:Object):void
		{
			if (value != null && value.hasOwnProperty("toArray")) {
				value = value.toArray();
			}
			super.flash_proxy::object = value;
		}
	}
}