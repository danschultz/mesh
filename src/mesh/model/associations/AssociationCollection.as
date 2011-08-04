package mesh.model.associations
{
	import collections.ArraySequence;
	import collections.HashSet;
	
	import flash.errors.IllegalOperationError;
	import flash.utils.flash_proxy;
	
	import mesh.core.object.copy;
	import mesh.model.Entity;
	import mesh.services.Request;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	
	use namespace flash_proxy;
	
	public dynamic class AssociationCollection extends Association implements IList
	{
		private var _originalEntities:Array;
		private var _mirroredEntities:ArraySequence;
		private var _removedEntities:HashSet = new HashSet();
		
		/**
		 * @copy AssociationProxy#AssociationProxy()
		 */
		public function AssociationCollection(source:Entity, definition:HasManyDefinition)
		{
			super(source, definition);
			object = [];
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
			addItemAt(item, length);
		}
		
		/**
		 * @inheritDoc
		 */
		public function addItemAt(item:Object, index:int):void
		{
			callbackIfNotNull("beforeAdd", Entity( item ));
			object.addItemAt(item, index);
		}
		
		/**
		 * Returns either a new entity or an array of new entities of the associated type.
		 * These object will be instantiated from the passed in properties and their relationships
		 * populated. However, they will not be saved.
		 * 
		 * @param properties The properties for each new entity.
		 * @return Either a new entity, or an array of new entities.
		 */
		public function build(...properties):*
		{
			var result:Array = [];
			for each (var property:Object in properties) {
				var entity:Entity = new definition.target();
				copy(property, entity);
				populateInverseAssociation(entity);
				result.push(entity);
			}
			return result.length == 1 ? result.pop() : result;
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
		 * Creates a new entity of the associated type that is populated with the given properties.
		 * 
		 * @param properties The properties to populate the new entity with.
		 * @return An executing operation that saves the entity to the backend.
		 */
		public function create(properties:Object):Request
		{
			var entity:Entity = build(properties);
			add(entity);
			return entity.save();
		}
		
		/**
		 * @inheritDoc
		 */
		public function getItemAt(index:int, prefetch:int = 0):Object
		{
			return object.getItemAt(index, prefetch);
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
					handleEntitiesAdded(event.items);
					break;
				case CollectionEventKind.REMOVE:
					handleEntitiesRemoved(event.items);
					break;
				case CollectionEventKind.RESET:
					handleEntitiesRemoved(_mirroredEntities.difference(object).toArray());
					handleEntitiesAdded(toArray());
					break;
			}
			
			if (event.kind != CollectionEventKind.UPDATE) {
				_mirroredEntities = new ArraySequence(object.source);
			}
			
			dispatchEvent(event.clone());
		}
		
		protected function handleEntitiesAdded(entities:Array):void
		{
			for each (var entity:Entity in entities) {
				_removedEntities.remove(entity);
				callbackIfNotNull("afterAdd", entity);
			}
		}
		
		protected function handleEntitiesRemoved(entities:Array):void
		{
			for each (var entity:Entity in entities) {
				if (entity.isPersisted) {
					_removedEntities.add(entity);
				}
				callbackIfNotNull("afterRemove", entity);
			}
		}
		
		private function handleEntityDestroyed(entity:Entity):void
		{
			remove(entity);
			_removedEntities.remove(entity);
		}
		
		/**
		 * @inheritDoc
		 */
		public function itemUpdated(item:Object, property:Object = null, oldValue:Object = null, newValue:Object = null):void
		{
			object.itemUpdated(item, property, oldValue, newValue);
		}
		
		private function loaded():void
		{
			snapshot();
		}
		
		private function populateInverseAssociation(entity:Entity):void
		{
			if (definition.hasInverse) {
				if (entity.hasOwnProperty(definition.inverse)) {
					// if the inverse relationship is an association, then we populate the inverse 
					// association's object. otherwise, we just set the property to the association's owner.
					if (entity[definition.inverse] is Association) {
						entity[definition.inverse].object = owner;
					} else {
						entity[definition.inverse] = owner;
					}
				} else {
					throw new IllegalOperationError("Inverse property '" + definition.inverse + "' not defined on " + entity.reflect.name);
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
			object.removeAll();
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
			callbackIfNotNull("beforeRemove", Entity( getItemAt(index) ));
			return object.removeItemAt(index);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function reset():void
		{
			object.removeEventListener(CollectionEvent.COLLECTION_CHANGE, handleEntitiesCollectionChange);
			
			object = undefined;
			_removedEntities.clear();
			
			super.reset();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function revert():void
		{
			super.revert();
			
			object = _originalEntities;
			
			for each (var entity:Entity in this) {
				entity.revert();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function setItemAt(item:Object, index:int):Object
		{
			return object.setItemAt(item, index);
		}
		
		private function snapshot():void
		{
			_originalEntities = toArray();
		}
		
		/**
		 * @inheritDoc
		 */
		public function toArray():Array
		{
			return object.toArray();
		}
		
		/**
		 * <code>true</code> if the collection doesn't contain any elements.
		 */
		public function get isEmpty():Boolean
		{
			return length == 0;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get length():int
		{
			return object.length;
		}
		
		/**
		 * @inheritDoc
		 */
		override flash_proxy function get dirtyEntities():Array
		{
			var result:Array = [];
			for each (var entity:Entity in toArray().concat(_removedEntities.toArray())) {
				if (entity.isDirty) {
					result.push(entity);
				}
			}
			return result;
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
		override flash_proxy function get object():*
		{
			return super.object;
		}
		override flash_proxy function set object(value:*):void
		{
			if (value is Entity) {
				value = [value];
			}
			
			if (value != null && (!(value is Array) && !value.hasOwnProperty("toArray"))) {
				throw new ArgumentError("AssociationCollection.object must be an Array, have a 'toArray' method, or be null.");
			}
			
			if (value != object) {
				if (object != null) {
					object.removeEventListener(CollectionEvent.COLLECTION_CHANGE, handleEntitiesCollectionChange);
				}
				
				if (value != null && value.hasOwnProperty("toArray")) {
					value = value.toArray();
				}
				
				for each (var entity:Entity in value) {
					callbackIfNotNull("beforeAdd", entity);
				}
				
				super.object = new ArrayCollection(value);
				
				if (_mirroredEntities == null) {
					_mirroredEntities = new ArraySequence(value);
				}
				
				object.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleEntitiesCollectionChange);
				object.dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.RESET));
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