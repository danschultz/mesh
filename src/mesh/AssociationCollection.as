package mesh
{
	import collections.ArrayList;
	import collections.ArraySet;
	
	import mx.collections.IList;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	
	import operations.EmptyOperation;
	import operations.Operation;

	public dynamic class AssociationCollection extends AssociationProxy implements IList
	{
		private var _mirroredEntities:collections.ArrayList;
		private var _originalEntities:collections.ArrayList;
		private var _removedEntities:ArraySet = new ArraySet();
		
		/**
		 * @copy AssociationProxy#AssociationProxy()
		 */
		public function AssociationCollection(source:Entity, relationship:Relationship)
		{
			super(source, relationship);
			target = [];
		}
		
		/**
		 * @inheritDoc
		 */
		public function addItem(item:Object):void
		{
			target.addItem(item);
		}
		
		/**
		 * @inheritDoc
		 */
		public function addItemAt(item:Object, index:int):void
		{
			target.addItemAt(item, index);
		}
		
		/**
		 * @inheritDoc
		 */
		public function getItemAt(index:int, prefetch:int = 0):Object
		{
			return target.getItemAt(index, prefetch);
		}
		
		/**
		 * @inheritDoc
		 */
		public function getItemIndex(item:Object):int
		{
			return _mirroredEntities.indexOf(item);
		}
		
		private function handleEntitiesCollectionChange(event:CollectionEvent):void
		{
			switch (event.kind) {
				case CollectionEventKind.ADD:
					_removedEntities.removeAll(event.items);
					_mirroredEntities.addAllAt(event.items, event.location);
					break;
				case CollectionEventKind.REMOVE:
					_removedEntities.addAll(event.items);
					_mirroredEntities.removeAll(event.items);
					break;
				case CollectionEventKind.RESET:
					_removedEntities.addAll(_mirroredEntities.difference(new collections.ArrayList(target.toArray())));
					_mirroredEntities = new collections.ArrayList(toArray());
					break;
			}
			
			dispatchEvent(event.clone());
		}
		
		/**
		 * @inheritDoc
		 */
		public function itemUpdated(item:Object, property:Object = null, oldValue:Object = null, newValue:Object = null):void
		{
			target.itemUpdated(item, property, oldValue, newValue);
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeAll():void
		{
			target.removeAll();
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeItemAt(index:int):Object
		{
			return target.removeItemAt(index);
		}
		
		override public function loaded():void
		{
			_originalEntities = new collections.ArrayList(toArray());
		}
		
		/**
		 * @inheritDoc
		 */
		override public function revert():void
		{
			super.revert();
			
			target = _originalEntities;
			
			for each (var entity:Entity in _mirroredEntities) {
				entity.revert();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function save(validate:Boolean = true, execute:Boolean = true):Operation
		{
			var operation:Operation = new EmptyOperation();
			
			for each (var entity:Entity in _mirroredEntities) {
				if (entity.isDirty) {
					operation = entity.save(validate).during(operation);
				}
			}
			
			for each (var removedEntity:Entity in _removedEntities) {
				if (removedEntity.isPersisted) {
					operation = removedEntity.destroy().during(operation);
				}
			}
			
			return operation;
		}
		
		/**
		 * @inheritDoc
		 */
		public function setItemAt(item:Object, index:int):Object
		{
			return target.setItemAt(item, index);
		}
		
		/**
		 * @inheritDoc
		 */
		public function toArray():Array
		{
			return target.toArray();
		}
		
		/**
		 * @inheritDoc
		 */
		public function get length():int
		{
			return target.length;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get isDirty():Boolean
		{
			return toArray().some(function(entity:Entity, index:int, array:Array):Boolean
			{
				return entity.isDirty;
			});
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get target():Object
		{
			return super.target;
		}
		override public function set target(value:Object):void
		{
			if (value != target) {
				if (target != null) {
					target.removeEventListener(CollectionEvent.COLLECTION_CHANGE, handleEntitiesCollectionChange);
				}
				
				if (value != null && value.hasOwnProperty("toArray")) {
					value = value.toArray();
				}
				
				super.target = new mx.collections.ArrayList(value as Array);
				_mirroredEntities = new collections.ArrayList(value);
				
				dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.RESET));
				target.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleEntitiesCollectionChange);
			}
		}
	}
}