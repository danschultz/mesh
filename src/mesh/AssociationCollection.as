package mesh
{
	import collections.ArraySet;
	import collections.HashSet;
	
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	
	import operations.EmptyOperation;
	import operations.Operation;

	public class AssociationCollection extends AssociationProxy implements IList
	{
		private var _entities:ArrayList = new ArrayList();
		private var _removedEntities:ArraySet = new ArraySet();
		
		public function AssociationCollection(source:Entity, relationship:Relationship)
		{
			super(source, relationship);
			
			_entities.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleEntitiesCollectionChange);
			target = _entities;
		}
		
		/**
		 * @inheritDoc
		 */
		public function addItem(item:Object):void
		{
			_entities.addItem(item);
		}
		
		/**
		 * @inheritDoc
		 */
		public function addItemAt(item:Object, index:int):void
		{
			_entities.addItemAt(item, index);
		}
		
		/**
		 * @inheritDoc
		 */
		public function getItemAt(index:int, prefetch:int = 0):Object
		{
			return _entities.getItemAt(index, prefetch);
		}
		
		/**
		 * @inheritDoc
		 */
		public function getItemIndex(item:Object):int
		{
			return _entities.getItemIndex(item);
		}
		
		private function handleEntitiesCollectionChange(event:CollectionEvent):void
		{
			switch (event.kind) {
				case CollectionEventKind.REMOVE:
					_removedEntities.addAll(event.items);
					break;
			}
			
			dispatchEvent(event.clone());
		}
		
		/**
		 * @inheritDoc
		 */
		public function itemUpdated(item:Object, property:Object = null, oldValue:Object = null, newValue:Object = null):void
		{
			_entities.itemUpdated(item, property, oldValue, newValue);
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeAll():void
		{
			_entities.removeAll();
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeItemAt(index:int):Object
		{
			return _entities.removeItemAt(index);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function save(validate:Boolean = true):Operation
		{
			var saveOperation:Operation = new EmptyOperation();
			for each (var entity:Entity in _entities.toArray()) {
				if (entity.isDirty) {
					saveOperation = entity.save().during(saveOperation);
				}
			}
			
			var removeOperation:Operation = new EmptyOperation();
			for each (var removedEntity:Entity in _removedEntities) {
				removeOperation = removedEntity.destroy().during(removeOperation);
			}
			
			return saveOperation.then(removeOperation);
		}
		
		/**
		 * @inheritDoc
		 */
		public function setItemAt(item:Object, index:int):Object
		{
			return _entities.setItemAt(item, index);
		}
		
		/**
		 * @inheritDoc
		 */
		public function toArray():Array
		{
			return _entities.toArray();
		}
		
		/**
		 * @inheritDoc
		 */
		public function get length():int
		{
			return _entities.length;
		}
	}
}