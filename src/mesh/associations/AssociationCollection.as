package mesh.associations
{
	import collections.ArrayList;
	import collections.ArraySet;
	import collections.HashSet;
	import collections.ISet;
	
	import flash.utils.flash_proxy;
	
	import mesh.Entity;
	
	import mx.collections.IList;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	
	import operations.FactoryOperation;
	import operations.Operation;
	import operations.SequentialOperation;
	
	import reflection.className;
	
	use namespace flash_proxy;
	
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
		 * @copy #addItem()
		 */
		public function add(item:Object):void
		{
			addItem(item);
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
		 * @copy mesh.Entity#findDirtyEntities()
		 */
		public function findDirtyEntities():ISet
		{
			var result:HashSet = new HashSet();
			for each (var entity:Entity in this) {
				result.addAll(entity.findDirtyEntities());
			}
			return result;
		}
		
		/**
		 * @copy mesh.Entity#findRemovedEntities()
		 */
		public function findRemovedEntities():ISet
		{
			return new HashSet(_removedEntities);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function fromVO(vo:Object, options:Object = null):void
		{
			if (!(vo is Array) && !(vo is IList)) {
				throw new ArgumentError("Expected an Array or IList, but got a " + className(vo));
			}
			
			var items:Array = [];
			for each (var item:Object in vo) {
				items.push(createEntityFromVOMapping(item, options));
			}
			target = items;
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
					populateBelongsToRelationships(event.items);
					_removedEntities.removeAll(event.items);
					break;
				case CollectionEventKind.REMOVE:
					_removedEntities.addAll(event.items);
					break;
				case CollectionEventKind.RESET:
					_removedEntities.addAll(_mirroredEntities.difference(new collections.ArrayList(target.toArray())));
					populateBelongsToRelationships(target.toArray());
					break;
			}
			
			if (event.kind != CollectionEventKind.UPDATE) {
				_mirroredEntities = new collections.ArrayList(toArray());
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
		override public function loaded():void
		{
			super.loaded();
			
			_originalEntities = new collections.ArrayList(toArray());
			
			for each (var entity:Entity in this) {
				entity.loaded();
			}
		}
		
		private function populateBelongsToRelationships(entities:Array):void
		{
			for each (var entity:Entity in entities) {
				for each (var relationship:Relationship in entity.descriptor.relationships) {
					if (relationship is BelongsToRelationship) {
						entity[relationship.property] = owner;
					}
				}
			}
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
			target.removeAll();
		}
		
		/**
		 * @copy #removeItemAt()
		 */
		public function removeAt(index:int):void
		{
			removeItemAt(index);
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
			return target.removeItemAt(index);
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
		override public function save(validate:Boolean = true):Operation
		{
			var beforeSave:SequentialOperation = new SequentialOperation();
			var afterSave:SequentialOperation = new SequentialOperation();
			var newEntities:Array = [];
			var persistedEntities:Array = [];
			
			for each (var entity:Entity in _mirroredEntities) {
				var isDirty:Boolean = entity.isDirty;
				
				if (isDirty) {
					beforeSave.add(entity.callbacksAsOperation("beforeSave"));
					afterSave.add(entity.callbacksAsOperation("afterSave"));
					
					if (entity.isNew) {
						newEntities.push(entity);
					} else if (isDirty) {
						persistedEntities.push(entity);
					}
				}
			}
			
			var saveOperation:Operation = beforeSave;
			if (newEntities.length > 0) {
				saveOperation = saveOperation.then( new FactoryOperation(Entity.adaptorFor(relationship.target).create, newEntities) );
			}
			if (persistedEntities.length > 0) {
				saveOperation = saveOperation.then( new FactoryOperation(Entity.adaptorFor(relationship.target).update, persistedEntities) );
			}
			saveOperation = saveOperation.then(afterSave);
			
			var beforeDestroy:SequentialOperation = new SequentialOperation();
			var afterDestroy:SequentialOperation = new SequentialOperation();
			var entitiesToRemove:Array = [];
			for each (var removedEntity:Entity in _removedEntities) {
				if (removedEntity.isPersisted) {
					beforeDestroy.add(removedEntity.callbacksAsOperation("beforeDestroy"));
					afterDestroy.add(removedEntity.callbacksAsOperation("afterDestroy"));
					entitiesToRemove.push(removedEntity);
				}
			}
			var destroyOperation:Operation = beforeDestroy;
			if (entitiesToRemove.length > 0) {
				destroyOperation = destroyOperation.then( new FactoryOperation(Entity.adaptorFor(relationship.target).destroy, entitiesToRemove) );
			}
			destroyOperation = destroyOperation.then(afterDestroy);
			
			return saveOperation.during(destroyOperation);
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
			return hasUnsavedRemovedEntities || toArray().some(function(entity:Entity, index:int, array:Array):Boolean
			{
				return entity.isDirty;
			});
		}
		
		/**
		 * <code>true</code> if this collection contains entities that have been removed, but not
		 * yet persisted.
		 */
		public function get hasUnsavedRemovedEntities():Boolean
		{
			for each (var entity:Entity in _removedEntities) {
				if (entity.isPersisted) {
					return true;
				}
			}
			return false;
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
			if (value != null && (!(value is Array) && !value.hasOwnProperty("toArray"))) {
				throw new ArgumentError("AssociationCollection.target must be an Array, have a toArray method, or be null.");
			}
			
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
	}
}